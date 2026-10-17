//
//  BorrowView.swift
//  BookNest
//
import SwiftUI
import SwiftData
import UserNotifications

struct BorrowView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
   
    let book: Book
    @State private var borrowerName = ""
    @State private var dueDate = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
    @State private var showSuccess = false
   
    var body: some View {
        NavigationStack {
            Form {
                Section("Book") {
                    Text(book.title)
                        .font(.headline)
                    Text("by \(book.author)")
                        .foregroundStyle(.secondary)
                    Text("Available: \(book.availableCopies)")
                }
               
                Section("Borrow Details") {
                    TextField("Your Name", text: $borrowerName)
                    DatePicker("Due Date", selection: $dueDate, in: Date()..., displayedComponents: .date)
                }
               
                Section {
                    Button("Confirm Borrow") {
                        borrowBook()
                    }
                    .disabled(borrowerName.trimmingCharacters(in: .whitespaces).isEmpty || book.availableCopies == 0)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Borrow Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Book borrowed successfully. You will be notified when it is due.")
            }
            .onAppear {
                requestNotificationPermission()
            }
        }
    }
   
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
   
    private func borrowBook() {
        guard book.availableCopies > 0 else { return }
       
        let loan = Loan(book: book, borrowerName: borrowerName.trimmingCharacters(in: .whitespaces))
        loan.dueDate = dueDate
        context.insert(loan)
       
        book.availableCopies -= 1
       
        scheduleOverdueNotification(for: loan)
       
        showSuccess = true
    }
   
    private func scheduleOverdueNotification(for loan: Loan) {
        let content = UNMutableNotificationContent()
        content.title = "Book Overdue"
        content.body = "\"\(loan.book?.title ?? "A book")\" borrowed by \(loan.borrowerName) is now overdue."
        content.sound = .default
       
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: loan.dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
       
        let request = UNNotificationRequest(identifier: loan.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
