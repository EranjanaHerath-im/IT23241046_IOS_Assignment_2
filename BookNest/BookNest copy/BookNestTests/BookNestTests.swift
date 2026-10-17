//
//  BookNestTests.swift
//  BookNestTests
//
import XCTest
@testable import BookNest

final class BookNestTests: XCTestCase {

    func testBookAvailability() {
        let book = Book(title: "Test Book", author: "Author", isbn: "123", category: "Novel", shelfNumber: "A1", totalCopies: 2)
        XCTAssertTrue(book.isAvailable)
        XCTAssertEqual(book.availableCopies, 2)
       
        book.availableCopies = 0
        XCTAssertFalse(book.isAvailable)
    }
   
    func testLoanOverdue() {
        let book = Book(title: "Test", author: "A", isbn: "1", category: "Novel", shelfNumber: "B1")
        let loan = Loan(book: book, borrowerName: "John", days: -1) // already overdue
        XCTAssertTrue(loan.isOverdue)
       
        let futureLoan = Loan(book: book, borrowerName: "Jane", days: 7)
        XCTAssertFalse(futureLoan.isOverdue)
    }
   
    func testUserRole() {
        let librarian = User(name: "Admin", username: "admin", role: .librarian)
        let borrower = User(name: "Student", username: "student", role: .borrower)
       
        XCTAssertEqual(librarian.role, .librarian)
        XCTAssertEqual(borrower.role, .borrower)
    }
}
