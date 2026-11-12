import SwiftUI
import FirebaseCore

@main
struct firebasetestApp: App {

    @StateObject private var viewModel = AuthViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if viewModel.isSignedIn {
                    ContentView()
                        .environmentObject(viewModel)
                } else {
                    LoginView()
                        .environmentObject(viewModel)
                }
            }
        }
    }
}
