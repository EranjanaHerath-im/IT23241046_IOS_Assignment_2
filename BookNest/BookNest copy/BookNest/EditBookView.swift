import SwiftUI
import SwiftData

struct EditBookView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
   
    @Bindable var book: Book
   
    @State private var title: String
    @State private var author: String
    @State private var isbn: String
    @State private var category: String
    @State private var shelfNumber: String
    @State private var totalCopies: Int
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showSuccess = false
   
    let categories = ["Novel", "Scientific", "Short Stories", "Biography", "History", "Technology", "Other"]
   
    init(book: Book) {
        self.book = book
        _title = State(initialValue: book.title)
        _author = State(initialValue: book.author)
        _isbn = State(initialValue: book.isbn)
        _category = State(initialValue: book.category)
        _shelfNumber = State(initialValue: book.shelfNumber)
        _totalCopies = State(initialValue: book.totalCopies)
        if let data = book.coverImageData {
            _selectedImage = State(initialValue: UIImage(data: data))
        }
    }
   
    var body: some View {
        NavigationStack {
            Form {
                Section("Book Information") {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    TextField("ISBN", text: $isbn)
                    TextField("Shelf Number", text: $shelfNumber)
                }
               
                Section("Cover Image") {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                       
                        Button("Remove Image", role: .destructive) {
                            selectedImage = nil
                        }
                    }
                   
                    Button("Choose Image") {
                        showImagePicker = true
                    }
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(image: $selectedImage)
                }
               
                Section("Category & Copies") {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                   
                    Stepper("Total Copies: \(totalCopies)", value: $totalCopies, in: 1...50)
                }
               
                Section {
                    Text("Available Copies: \(book.availableCopies)")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Edit Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(title.isEmpty || author.isEmpty || isbn.isEmpty)
                }
            }
            .alert("Changes Saved", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Book details have been updated.")
            }
        }
    }
   
    private func saveChanges() {
        book.title = title.trimmingCharacters(in: .whitespaces)
        book.author = author.trimmingCharacters(in: .whitespaces)
        book.isbn = isbn.trimmingCharacters(in: .whitespaces)
        book.category = category
        book.shelfNumber = shelfNumber.trimmingCharacters(in: .whitespaces)
        book.coverImageData = selectedImage?.jpegData(compressionQuality: 0.7)
       
        let difference = totalCopies - book.totalCopies
        book.totalCopies = totalCopies
        book.availableCopies = max(0, book.availableCopies + difference)
       
        showSuccess = true
    }
}
