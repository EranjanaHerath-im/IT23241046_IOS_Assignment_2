//
//  CategoryManagerView.swift
//  BookNest
//
import SwiftUI
import SwiftData

struct CategoryManagerView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \BookCategory.name) private var categories: [BookCategory]
   
    @State private var newCategoryName = ""
    @State private var editingCategory: BookCategory?
    @State private var editedName = ""
   
    var body: some View {
        NavigationStack {
            List {
                Section("Add New Category") {
                    HStack {
                        TextField("Category name", text: $newCategoryName)
                        Button("Add") {
                            addCategory()
                        }
                        .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
               
                Section("Existing Categories") {
                    if categories.isEmpty {
                        Text("No categories yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(categories) { category in
                            HStack {
                                if editingCategory?.id == category.id {
                                    TextField("Name", text: $editedName)
                                    Button("Save") {
                                        saveEdit(category)
                                    }
                                    .buttonStyle(.borderedProminent)
                                } else {
                                    Text(category.name)
                                    Spacer()
                                    Button("Edit") {
                                        editingCategory = category
                                        editedName = category.name
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                        .onDelete(perform: deleteCategories)
                    }
                }
            }
            .navigationTitle("Manage Categories")
            .toolbar {
                EditButton()
            }
        }
    }
   
    private func addCategory() {
        let name = newCategoryName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
       
        // Prevent duplicates
        if categories.contains(where: { $0.name.lowercased() == name.lowercased() }) {
            return
        }
       
        let category = BookCategory(name: name)
        context.insert(category)
        newCategoryName = ""
    }
   
    private func saveEdit(_ category: BookCategory) {
        let name = editedName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        category.name = name
        editingCategory = nil
    }
   
    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            context.delete(categories[index])
        }
    }
}

#Preview {
    CategoryManagerView()
}

