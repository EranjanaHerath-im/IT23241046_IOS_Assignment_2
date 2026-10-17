//
//  Models.swift
//  BookNest
//
//  Created by STUDENT on 2026-10-16.
//

import Foundation
import SwiftData

enum UserRole: String, Codable {
    case librarian
    case borrower
}

@Model
class User {
    var id: UUID
    var name: String
    var username: String
    var role: UserRole
   
    init(name: String, username: String, role: UserRole) {
        self.id = UUID()
        self.name = name
        self.username = username
        self.role = role
    }
}

@Model
class Book {
    var id: UUID
    var title: String
    var author: String
    var isbn: String
    var category: String          // e.g. Novel, Scientific, Short Stories
    var shelfNumber: String
    var totalCopies: Int
    var availableCopies: Int
    var coverImageName: String?   // for local images later
    var coverImageData: Data?

    var isAvailable: Bool {
        availableCopies > 0
    }
   
    init(title: String, author: String, isbn: String, category: String, shelfNumber: String, totalCopies: Int = 1, coverImageData: Data? = nil) {
        self.id = UUID()
        self.title = title
        self.author = author
        self.isbn = isbn
        self.category = category
        self.shelfNumber = shelfNumber
        self.totalCopies = totalCopies
        self.availableCopies = totalCopies
        self.coverImageData = coverImageData
    }
}

@Model
class BookCategory {
    var id: UUID
    var name: String
   
    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}

@Model
class Loan {
    var id: UUID
    var book: Book?
    var borrowerName: String
    var borrowDate: Date
    var dueDate: Date
    var returnedDate: Date?
   
    var isOverdue: Bool {
        returnedDate == nil && dueDate < Date()
    }
   
    init(book: Book, borrowerName: String, days: Int = 14) {
        self.id = UUID()
        self.book = book
        self.borrowerName = borrowerName
        self.borrowDate = Date()
        self.dueDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        self.returnedDate = nil
    }
}

