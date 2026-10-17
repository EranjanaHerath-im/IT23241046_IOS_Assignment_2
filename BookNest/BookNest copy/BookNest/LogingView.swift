import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var context
    @Query private var users: [User]
   
    @State private var username = ""
    @State private var selectedRole: UserRole = .borrower
    @State private var currentUser: User?
    @State private var isLoggedIn = false
   
    var body: some View {
        if isLoggedIn, let user = currentUser {
            MainTabView(user: user)
        } else {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
               
                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Image(systemName: "books.vertical.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(AppTheme.primary)
                       
                        Text("BookNest")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                       
                        Text("Your Smart Library Companion")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                   
                    VStack(spacing: 20) {
                        TextField("Enter your name", text: $username)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(AppTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                       
                        Picker("I am a", selection: $selectedRole) {
                            Text("Borrower").tag(UserRole.borrower)
                            Text("Librarian").tag(UserRole.librarian)
                        }
                        .pickerStyle(.segmented)
                       
                        Button {
                            login()
                        } label: {
                            Text("Continue")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .background(AppTheme.primary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .disabled(username.trimmingCharacters(in: .whitespaces).isEmpty)
                        .opacity(username.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1)
                    }
                    .cardStyle()
                }
                .padding(.horizontal, 24)
            }
        }
    }
   
    private func login() {
        let cleanName = username.trimmingCharacters(in: .whitespaces)
       
        if let existingUser = users.first(where: { $0.username.lowercased() == cleanName.lowercased() }) {
            currentUser = existingUser
        } else {
            let newUser = User(name: cleanName, username: cleanName, role: selectedRole)
            context.insert(newUser)
            currentUser = newUser
        }
       
        isLoggedIn = true
    }
}
