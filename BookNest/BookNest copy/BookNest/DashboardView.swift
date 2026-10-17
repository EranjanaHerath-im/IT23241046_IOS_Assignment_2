//
//  DashboardView.swift
//  BookNest
//
import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var books: [Book]
    @Query private var loans: [Loan]
   
    var activeLoans: [Loan] {
        loans.filter { $0.returnedDate == nil }
    }
   
    var overdueLoans: [Loan] {
        loans.filter { $0.isOverdue }
    }
   
    var totalBooks: Int { books.count }
    var totalCopies: Int { books.reduce(0) { $0 + $1.totalCopies } }
    var availableCopies: Int { books.reduce(0) { $0 + $1.availableCopies } }
   
    var body: some View {
        NavigationStack {
            List {
                Section("Overview") {
                    StatRow(title: "Total Books", value: "\(totalBooks)")
                    StatRow(title: "Total Copies", value: "\(totalCopies)")
                    StatRow(title: "Available Copies", value: "\(availableCopies)")
                    StatRow(title: "Active Loans", value: "\(activeLoans.count)")
                    StatRow(title: "Overdue Books", value: "\(overdueLoans.count)", isWarning: overdueLoans.count > 0)
                }
               
                if !overdueLoans.isEmpty {
                    Section("Overdue Loans") {
                        ForEach(overdueLoans) { loan in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(loan.book?.title ?? "Unknown Book")
                                    .font(.headline)
                                Text("Borrowed by: \(loan.borrowerName)")
                                    .font(.subheadline)
                                Text("Due: \(loan.dueDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Dashboard")
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    var isWarning: Bool = false
   
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(isWarning ? .red : .primary)
        }
    }
}

#Preview {
    DashboardView()
}
