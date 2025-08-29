import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showAccountPreferences: Bool = false
    @State private var showSecurity: Bool = false
    

    var body: some View {
        VStack {
            HStack (spacing: 10) {
                Text("Settings")
                    .font(.custom("OpenSans-SemiBold", size: 24))
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        dismiss()
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color("TextColor"))
                        .frame(width: 100, height: 100)
                }
            }
            .padding(.horizontal, 25)
            .padding(.top, 20)
            
            VStack (spacing: 10) {
                
                Button(action: {
                    withAnimation {
                        showAccountPreferences = true
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(Color("TextFieldBackground"))
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color("TextFieldBorder"), lineWidth: 1)
                            )
                        
                        HStack (spacing: 10) {
                            Image("generalIcon")
                                .frame(width: 20, height: 20)
                            
                            Text("Account Preferences")
                                .font(.custom("OpenSans-Regular", size: 17))
                                .foregroundColor(Color("TextColor"))
                            
                            Spacer()
                        }
                        .padding(.horizontal, 15)
                    }
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
                
                
                Button(action: {
                    withAnimation {
                        showSecurity = true
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(Color("TextFieldBackground"))
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color("TextFieldBorder"), lineWidth: 1)
                            )
                        
                        HStack (spacing: 10) {
                            Image("securityIcon")
                                .frame(width: 20, height: 20)
                            
                            Text("Security")
                                .font(.custom("OpenSans-Regular", size: 17))
                                .foregroundColor(Color("TextColor"))
                            
                            Spacer()
                        }
                        .padding(.horizontal, 15)
                    }
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AppBackgroundColor"))
        // .ignoresSafeArea(.all, edges: .all)
        .fullScreenCover(isPresented: $showAccountPreferences) {
            PreferencesView()
        }
        .fullScreenCover(isPresented: $showSecurity) {
            SecurityView()
        }
    }
}
