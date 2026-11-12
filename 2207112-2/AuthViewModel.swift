import Foundation
import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject {

    @Published var user: User?
    @Published var isSignedIn = false
    @Published var errorMessage = ""      // red text on login / register pages
    @Published var successMessage = ""    // green text after registering

    init() {
        self.user = Auth.auth().currentUser
        self.isSignedIn = user != nil
    }

    // ---------- LOGIN ----------
    func signIn(email: String, password: String) {
        errorMessage = ""
        successMessage = ""
        let cleanEmail = email.trimmingCharacters(in: .whitespaces)
        Auth.auth().signIn(withEmail: cleanEmail, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            self.user = result?.user
            self.isSignedIn = true
        }
    }

    // ---------- REGISTER ----------
    // onSuccess is the code the Register page wants to run when the account is created
    func signUp(email: String, password: String, onSuccess: @escaping () -> Void) {
        errorMessage = ""
        let cleanEmail = email.trimmingCharacters(in: .whitespaces)
        Auth.auth().createUser(withEmail: cleanEmail, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            // Firebase logs a new user in automatically, so log out
            // to make them log in manually
            do {
                try Auth.auth().signOut()
            } catch {
                print("Sign out error: \(error.localizedDescription)")
            }
            self.user = nil
            self.isSignedIn = false
            self.successMessage = "Account created! Please log in."
            onSuccess()
        }
    }

    // ---------- LOGOUT ----------
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Sign out error: \(error.localizedDescription)")
        }
        user = nil
        isSignedIn = false
        errorMessage = ""
        successMessage = ""
    }
}
