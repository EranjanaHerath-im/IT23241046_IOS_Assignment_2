//
//  AddBookView.swift
//  BookNest
//
import SwiftUI
import SwiftData

struct AddBookView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
   
    var prefilledISBN: String?
   
    @State private var title = ""
    @State private var author = ""
    @State private var isbn = ""
    @State private var category = "Novel"
    @State private var shelfNumber = ""
    @State private var totalCopies = 1
    @State private var showSuccess = false
   
    let categories = ["Novel", "Scientific", "Short Stories", "Biography", "History", "Technology", "Other"]
   
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
            }
            .navigationTitle(prefilledISBN == nil ? "Add Book" : "Add Scanned Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveBook()
                    }
                    .disabled(title.isEmpty || author.isEmpty || isbn.isEmpty)
                }
            }
            .onAppear {
                if let isbn = prefilledISBN {
                    self.isbn = isbn
                }
            }
            .alert("Book Added", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("\"\(title)\" has been added to the library.")
            }
        }
    }
   
    private func saveBook() {
        let imageData = selectedImage?.jpegData(compressionQuality: 0.7)
        let book = Book(
            title: title.trimmingCharacters(in: .whitespaces),
            author: author.trimmingCharacters(in: .whitespaces),
            isbn: isbn.trimmingCharacters(in: .whitespaces),
            category: category,
            shelfNumber: shelfNumber.trimmingCharacters(in: .whitespaces),
            totalCopies: totalCopies,
            coverImageData: imageData
        )
        context.insert(book)
        showSuccess = true
    }
}
