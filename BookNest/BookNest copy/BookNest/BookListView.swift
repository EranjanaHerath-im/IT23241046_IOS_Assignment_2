import SwiftUI
import SwiftData
import CoreML

struct BookListView: View {
    let user: User
    @Query private var books: [Book]
    @Query private var categories: [BookCategory]
    @Query private var loans: [Loan]
   
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var showOnlyAvailable = false
    @State private var expandedBookID: UUID?
    @Namespace private var animationNamespace
   
    var allCategories: [String] {
        let cats = Set(books.map { $0.category })
        return ["All"] + cats.sorted()
    }
   
    var filteredBooks: [Book] {
        books.filter { book in
            let matchesSearch = searchText.isEmpty ||
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.author.localizedCaseInsensitiveContains(searchText) ||
                book.isbn.localizedCaseInsensitiveContains(searchText) ||
                book.category.localizedCaseInsensitiveContains(searchText) ||
                book.shelfNumber.localizedCaseInsensitiveContains(searchText)
           
            let matchesCategory = selectedCategory == "All" || book.category == selectedCategory
            let matchesAvailability = !showOnlyAvailable || book.isAvailable
           
            return matchesSearch && matchesCategory && matchesAvailability
        }
    }
   
    var groupedBooks: [String: [Book]] {
        Dictionary(grouping: filteredBooks, by: { $0.category })
    }
   
    var recommendedBooks: [Book] {
        let predictedCategory = predictCategory() ?? "Novel"
        let recommended = books.filter { $0.category == predictedCategory && $0.isAvailable }
        if recommended.isEmpty {
            return Array(books.filter { $0.isAvailable }.prefix(8))
        }
        return Array(recommended.prefix(8))
    }
   
    private func predictCategory() -> String? {
        do {
            let model = try BookCategoryClassifier(configuration: MLModelConfiguration())
            let prediction = try model.prediction(text: "science technology research")
            return prediction.label
        } catch {
            print("Core ML prediction failed: \(error)")
            return nil
        }
    }
   
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if searchText.isEmpty && !recommendedBooks.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recommended for You")
                            .font(.headline)
                            .padding(.horizontal)
                       
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(recommendedBooks) { book in
                                    RecommendationCard(book: book)
                                        .onTapGesture {
                                            withAnimation(.spring()) {
                                                expandedBookID = book.id
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)
                    .background(AppTheme.background)
                }
               
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(allCategories, id: \.self) { category in
                            Button(category) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedCategory = category
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? AppTheme.primary : AppTheme.cardBackground)
                            .foregroundStyle(selectedCategory == category ? .white : .primary)
                            .clipShape(Capsule())
                        }
                       
                        Toggle("Available Only", isOn: $showOnlyAvailable)
                            .toggleStyle(.button)
                            .tint(AppTheme.primary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(AppTheme.background)
               
                List {
                    if filteredBooks.isEmpty {
                        ContentUnavailableView("No Books Found", systemImage: "book.closed", description: Text("Try a different search or filter"))
                    } else {
                        ForEach(groupedBooks.keys.sorted(), id: \.self) { category in
                            Section(category) {
                                ForEach(groupedBooks[category] ?? []) { book in
                                    BookRow(
                                        book: book,
                                        isExpanded: expandedBookID == book.id,
                                        user: user,
                                        namespace: animationNamespace,
                                        onToggleExpand: {
                                            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                                                expandedBookID = expandedBookID == book.id ? nil : book.id
                                            }
                                        }
                                    )
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        if user.role == .librarian {
                                            Button(role: .destructive) {
                                                // Handled inside BookRow
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    try? await Task.sleep(nanoseconds: 600_000_000)
                }
            }
            .searchable(text: $searchText, prompt: "Search title, author, ISBN, shelf, category...")
            .navigationTitle("Discover")
            .toolbar {
                if user.role == .librarian {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            NavigationLink("Scan ISBN") { ScannerView() }
                            NavigationLink("Add Book Manually") { AddBookView() }
                            NavigationLink("Manage Categories") { CategoryManagerView() }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(AppTheme.primary)
                        }
                    }
                }
            }
        }
    }
}

struct RecommendationCard: View {
    let book: Book
   
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RoundedRectangle(cornerRadius: 10)
                .fill(AppTheme.primary.opacity(0.15))
                .frame(width: 110, height: 150)
                .overlay(
                    Image(systemName: "book.closed.fill")
                        .font(.largeTitle)
                        .foregroundStyle(AppTheme.primary)
                )
           
            Text(book.title)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .frame(width: 110, alignment: .leading)
           
            Text(book.category)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

struct BookRow: View {
    let book: Book
    let isExpanded: Bool
    let user: User
    var namespace: Namespace.ID
    var onToggleExpand: () -> Void
    @Environment(\.modelContext) private var context
    @Query private var loans: [Loan]
   
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let data = book.coverImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppTheme.primary.opacity(0.2))
                        .frame(width: 50, height: 70)
                        .overlay(Image(systemName: "book.closed").foregroundStyle(AppTheme.primary))
                }
               
                VStack(alignment: .leading) {
                    Text(book.title).font(.headline)
                    Text(book.isAvailable ? "Available" : "Not Available")
                        .font(.caption)
                        .foregroundStyle(book.isAvailable ? .green : .red)
                }
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onToggleExpand()
            }
           
            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    DetailRow(label: "Author", value: book.author)
                    DetailRow(label: "ISBN", value: book.isbn)
                    DetailRow(label: "Shelf", value: book.shelfNumber)
                    DetailRow(label: "Category", value: book.category)
                    DetailRow(label: "Available", value: "\(book.availableCopies) / \(book.totalCopies)")
                   
                    if user.role == .borrower {
                        if book.isAvailable {
                            NavigationLink(destination: BorrowView(book: book)) {
                                Text("Borrow This Book")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.top, 4)
                        } else if hasActiveLoan {
                            Button("Cancel Borrow / Return") {
                                returnBook()
                            }
                            .buttonStyle(.bordered)
                            .tint(.orange)
                            .padding(.top, 4)
                        }
                    }
                   
                    if user.role == .librarian {
                        HStack {
                            NavigationLink(destination: EditBookView(book: book)) {
                                Text("Edit")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                           
                            Button("Delete", role: .destructive) {
                                deleteBook()
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .font(.subheadline)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 4)
    }
   
    private var hasActiveLoan: Bool {
        loans.contains { $0.book?.id == book.id && $0.borrowerName == user.name && $0.returnedDate == nil }
    }
   
    private func returnBook() {
        if let loan = loans.first(where: { $0.book?.id == book.id && $0.borrowerName == user.name && $0.returnedDate == nil }) {
            loan.returnedDate = Date()
            if book.availableCopies < book.totalCopies {
                book.availableCopies += 1
            }
        }
    }
   
    private func deleteBook() {
        withAnimation { context.delete(book) }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label + ":").foregroundStyle(.secondary)
            Text(value)
        }
    }
}
