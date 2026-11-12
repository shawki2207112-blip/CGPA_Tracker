import SwiftUI

struct LoginView: View {

    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false

    var body: some View {
        NavigationStack {
            ZStack {
                // colourful background
                LinearGradient(colors: [Color.blue, Color.purple],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {

                        // ---------- welcome message ----------
                        VStack(spacing: 10) {
                            Image(systemName: "graduationcap.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.white)
                                .padding(24)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())

                            Text("Welcome Back")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("Log in to track your CGPA")
                                .foregroundColor(Color.white.opacity(0.85))
                        }
                        .padding(.top, 60)

                        // ---------- login card ----------
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

                            // password box with show / hide button
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                if showPassword {
                                    TextField("Password", text: $password)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                } else {
                                    SecureField("Password", text: $password)
                                }
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.12))
                            .cornerRadius(14)

                            // green message after registering
                            if authViewModel.successMessage != "" {
                                Text(authViewModel.successMessage)
                                    .font(.footnote)
                                    .foregroundColor(.green)
                            }

                            // red error message
                            if authViewModel.errorMessage != "" {
                                Text(authViewModel.errorMessage)
                                    .font(.footnote)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }

                            // login button
                            Button("Login") {
                                if email == "" || password == "" {
                                    authViewModel.errorMessage = "Please enter your email and password"
                                } else {
                                    authViewModel.signIn(email: email, password: password)
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [Color.blue, Color.purple],
                                               startPoint: .leading,
                                               endPoint: .trailing)
                            )
                            .cornerRadius(14)
                            .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
                        .padding(.horizontal, 24)

                        // ---------- no account? create one ----------
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(Color.white.opacity(0.85))
                            NavigationLink(destination: RegisterView()) {
                                Text("Create one")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .underline()
                            }
                        }
                        .font(.subheadline)
                        .padding(.bottom, 30)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                authViewModel.errorMessage = ""
            }
        }
    }
}
