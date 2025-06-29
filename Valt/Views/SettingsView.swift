import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @Binding var isShowingOverlay: Bool
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack {
            HStack {
                Text("Settings")
                    .font(.custom("OpenSans-Regular", size: 23))
                    .foregroundColor(Color("TextColor"))
                Spacer()
                Button(action: {
                    withAnimation {
                        isShowingOverlay = false // Dismiss the overlay
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
            .padding(.leading, 25)
            .padding(.trailing, 25)
            .padding(.top, 25)
            
            Spacer()
            VStack {
                Button(action: {
                    do {
                            try Auth.auth().signOut()
                            authViewModel.isAuthenticated = false
                            print("Successfully signed out.")
                        } catch {
                            print("Error signing out: \(error.localizedDescription)")
                        }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 150, height: 50)
                            .background(Color("BubbleColor"))
                        
                        Text("Sign Out")
                            .font(.custom("OpenSans-SemiBold", size: 19))
                            .foregroundColor(.white)
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AppBackgroundColor")) // Distinct background for Settings overlay
        .padding(.leading, UIScreen.main.bounds.width * 0.20)
        // .ignoresSafeArea(.all, edges: .all) // Covers status bar and tab bar when active
    }
}
