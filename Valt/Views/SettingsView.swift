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
            VStack (spacing: 10) {
                ZStack {
                    HStack (spacing: 8) {
                        Image("generalIcon")
                            .frame(width: 20, height: 20)
                        Text("General")
                            .foregroundColor(Color("TextColor"))
                            .font(.custom("OpenSans-Regular", size: 17))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color("BubbleColor"))
                        .frame(maxWidth: .infinity, maxHeight: 45)
                }
                
                ZStack {
                    HStack (spacing: 8) {
                        Image("activityIcon")
                            .frame(width: 20, height: 20)
                        Text("Activity")
                            .foregroundColor(Color("TextColor"))
                            .font(.custom("OpenSans-Regular", size: 17))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color("BubbleColor"))
                        .frame(maxWidth: .infinity, maxHeight: 45)
                }
                
                ZStack {
                    HStack (spacing: 8) {
                        Image("appearanceIcon")
                            .frame(width: 20, height: 20)
                        Text("Appearance")
                            .foregroundColor(Color("TextColor"))
                            .font(.custom("OpenSans-Regular", size: 17))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color("BubbleColor"))
                        .frame(maxWidth: .infinity, maxHeight: 45)
                }
                
                ZStack {
                    HStack (spacing: 8) {
                        Image("securityIcon")
                            .frame(width: 20, height: 20)
                        Text("Security")
                            .foregroundColor(Color("TextColor"))
                            .font(.custom("OpenSans-Regular", size: 17))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color("BubbleColor"))
                        .frame(maxWidth: .infinity, maxHeight: 45)
                }
                
            }
            .padding(.horizontal, 30)
            
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
                        Text("Sign Out")
                            .font(.custom("OpenSans-SemiBold", size: 19))
                            .foregroundColor(.white)
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 150, height: 50)
                            .background(Color("BubbleColor"))
                    }
                }
            }
        }
        .padding(.vertical, 70)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AppBackgroundColor"))
        .padding(.leading, UIScreen.main.bounds.width * 0.20)
        .ignoresSafeArea(.all, edges: .all)
    }
}
