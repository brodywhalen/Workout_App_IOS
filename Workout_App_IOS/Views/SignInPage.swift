import SwiftUI
import Supabase
import GoogleSignIn


// --- Configuration Helper ---
// This helper safely reads values from your Info.plist file.
enum SupabaseConfig {
    static var url: URL = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "SupabaseURL") as? String else {
            fatalError("SupabaseURL not found in Info.plist. Please add it.")
        }
        guard let url = URL(string: urlString) else {
            fatalError("Invalid SupabaseURL in Info.plist.")
        }
        return url
    }()

    static var key: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SupabaseKey") as? String else {
            fatalError("SupabaseKey not found in Info.plist. Please add it.")
        }
        return key
    }()
}

let supabase = SupabaseClient(
  supabaseURL: SupabaseConfig.url,
  supabaseKey: SupabaseConfig.key
)

@MainActor
class AuthViewModel: ObservableObject {
    // This will hold the user's session and update the UI when it changes.
    @Published var session: Session?

    init() {
        // 2. Set up a listener that fires whenever the auth state changes.
        // This is the key to making your UI react automatically to logins and logouts.
        Task {
            for await state in supabase.auth.authStateChanges {
                // The session is nil if the user is logged out.
                self.session = state.session
            }
        }
    }
}

struct SignInPage: View {
    // State to manage and display potential errors to the user.
    @State private var errorMessage: String?
    @StateObject private var authViewModel: AuthViewModel = AuthViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text("Login State:\(authViewModel.session == nil ? "Logged Out" : "Logged In") ")
            // The button that initiates the Google Sign-In flow.
            Button(action: {
                // We wrap the asynchronous sign-in logic in a Task.
                Task {
                    await signInWithGoogle()
                }
            }) {
                // A standard "Sign in with Google" button style.
                HStack {
                    Image("google_logo") // Assumes you have a "google_logo" image in your assets.
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    
                    Text("Sign in with Google")
                        .font(.headline)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .foregroundColor(Color(.label))
                .cornerRadius(10)
                .shadow(radius: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
            }
            .padding(.horizontal)

            // Display an error message if the sign-in process fails.
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }
            Button("Sign Out") {
                Task {
                    do {
                        try await supabase.auth.signOut()
                        // The user is now signed out.
                        // Your app's UI should update automatically if you've set up a state listener (more on this below).
                    } catch {
                        print("Error signing out: \(error.localizedDescription)")
                    }
                }
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        // Log out button

    }

    /// Handles the entire Google Sign-In and Supabase authentication flow.
    private func signInWithGoogle() async {
        errorMessage = nil // Reset error message before starting a new attempt.
        
        do {
            // 1. Get the top-most presenting view controller.
            // This is a crucial step for bridging UIKit's presentation logic into SwiftUI.
            guard let rootViewController = Utilities.getRootViewController() else {
                print("Error: Could not find a root view controller.")
                errorMessage = "Could not start sign-in process."
                return
            }

            // 2. Start the Google Sign-In flow.
            // This will present the Google Sign-In sheet to the user.
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

            // 3. Extract the ID token from the result.
            // This token is what Supabase will use to verify the user's identity.
            guard let idToken = result.user.idToken?.tokenString else {
                print("Error: No idToken found in Google Sign-In result.")
                errorMessage = "Authentication failed: Missing ID token."
                return
            }
            
            // The access token might also be useful, depending on your needs.
            let accessToken = result.user.accessToken.tokenString

            // 4. Authenticate with Supabase using the Google ID token.
            // This exchanges the Google credential for a Supabase session.
             try await supabase.auth.signInWithIdToken(
                 credentials: OpenIDConnectCredentials(
                     provider: .google,
                     idToken: idToken,
                     accessToken: accessToken
                 )
             )
            
            print("Successfully signed in with Supabase!")
            // Handle successful sign-in, e.g., navigate to the main content view.

        } catch {
            // Handle any errors that occur during the process.
            print("Error during Google Sign-In or Supabase auth: \(error.localizedDescription)")
            errorMessage = "An error occurred: \(error.localizedDescription)"
        }
    }
}

/// A helper utility to find the application's key window and root view controller.
enum Utilities {
    static func getRootViewController() -> UIViewController? {
        // Find the first active UIWindowScene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        
        // Get the key window for that scene
        guard let rootViewController = windowScene.windows.first?.rootViewController else {
            return nil
        }
        
        return rootViewController
    }
}


struct GoogleSignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInPage()
    }
}

