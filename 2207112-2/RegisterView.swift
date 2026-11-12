import SwiftUI

struct RegisterView: View {

    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss      // used to go back to the login page

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.purple, Color.blue],
                           startPoint: .topTrailing,
                           endPoint: .bottomLeading)
                .ignoresSafeArea()

            VStack {

                // back button
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                ScrollView {
                    VStack(spacing: 28) {

                        // ---------- heading ----------
                        VStack(spacing: 10) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 44))
                                .foregroundColor(.white)
                                .padding(24)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())

                            Text("Create Account")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("Register to save your own courses")
                                .foregroundColor(Color.white.opacity(0.85))
                        }
                        .padding(.top, 20)

                        // ---------- register card ----------
                        VStack(spacing: 16) {

                            // email box
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.gray)
                                TextField("Email", text: $email)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .keyboardType(.emailAddress)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.12))
                            .cornerRadius(14)

                            // password box
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                if showPassword {
                                    TextField("Password (min 6 characters)", text: $password)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                } else {
                                    SecureField("Password (min 6 characters)", text: $password)
                                }
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.12))
                            .cornerRadius(14)

                            // confirm password box
                            HStack {
                                Image(systemName: "lock.rotation")
                                    .foregroundColor(.gray)
                                if showPassword {
                                    TextField("Confirm password", text: $confirmPassword)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                } else {
                                    SecureField("Confirm password", text: $confirmPassword)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.12))
                            .cornerRadius(14)

                            // red error message
                            if authViewModel.errorMessage != "" {
                                Text(authViewModel.errorMessage)
                                    .font(.footnote)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }

                            // register button
                            Button("Register") {
                                if email == "" {
                                    authViewModel.errorMessage = "Please enter your email"
                                } else if password.count < 6 {
                                    authViewModel.errorMessage = "Password must be at least 6 characters"
                                } else if password != confirmPassword {
                                    authViewModel.errorMessage = "Passwords do not match"
                                } else {
                                    // when the account is created, go back to the login page
                                    authViewModel.signUp(email: email, password: password) {
                                        dismiss()
                                    }
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [Color.purple, Color.blue],
                                               startPoint: .leading,
                                               endPoint: .trailing)
                            )
                            .cornerRadius(14)
                            .shadow(color: Color.purple.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
                        .padding(.horizontal, 24)

                        // ---------- already have an account ----------
                        HStack {
                            Text("Already have an account?")
                                .foregroundColor(Color.white.opacity(0.85))
                            Button("Log in") {
                                dismiss()
                            }
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        }
                        .font(.subheadline)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            authViewModel.errorMessage = ""
            authViewModel.successMessage = ""
        }
    }
}
