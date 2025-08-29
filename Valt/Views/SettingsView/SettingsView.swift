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
                
                Button { dismiss() } label: {
                    ZStack {
                        Ellipse()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color("BubbleColor"))
                        Image("exitDynamicIcon")
                            .frame(width: 38, height: 38)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 25)
            .padding(.top, 20)
            
            VStack (spacing: 10) {
                
                NavigationLink {
                    PreferencesView()
                        .toolbar(.hidden, for: .navigationBar)   // hide default nav bar
                        .navigationBarBackButtonHidden(true)     // hide back chevron
                        .ignoresSafeArea()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(Color("TextFieldBackground"))
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color("TextFieldBorder"), lineWidth: 1)
                            )
                        HStack (spacing: 10) {
                            Image("userIcon")
                                .frame(width: 20, height: 20)
                            Text("Account Preferences")
                                .font(.custom("OpenSans-Regular", size: 17))
                                .foregroundColor(Color("TextColor"))
                            Spacer()
                        }
                        .padding(.horizontal, 15)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink {
                    DataView()
                        .toolbar(.hidden, for: .navigationBar)   // hide default nav bar
                        .navigationBarBackButtonHidden(true)     // hide back chevron
                        .ignoresSafeArea()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(Color("TextFieldBackground"))
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color("TextFieldBorder"), lineWidth: 1)
                            )
                        HStack (spacing: 10) {
                            Image("dataIcon")
                                .frame(width: 20, height: 20)
                            Text("Data Privacy")
                                .font(.custom("OpenSans-Regular", size: 17))
                                .foregroundColor(Color("TextColor"))
                            Spacer()
                        }
                        .padding(.horizontal, 15)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink {
                    ActivityView()
                        .toolbar(.hidden, for: .navigationBar)   // hide default nav bar
                        .navigationBarBackButtonHidden(true)     // hide back chevron
                        .ignoresSafeArea()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(Color("TextFieldBackground"))
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color("TextFieldBorder"), lineWidth: 1)
                            )
                        HStack (spacing: 10) {
                            Image("activityIcon")
                                .frame(width: 20, height: 20)
                            Text("Activity")
                                .font(.custom("OpenSans-Regular", size: 17))
                                .foregroundColor(Color("TextColor"))
                            Spacer()
                        }
                        .padding(.horizontal, 15)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                
                NavigationLink {
                    SecurityView()
                        .toolbar(.hidden, for: .navigationBar)   // hide default nav bar
                        .navigationBarBackButtonHidden(true)     // hide back chevron
                        .ignoresSafeArea()
                } label: {
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
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 25)
            
            Spacer()
            
            HStack {
                Button(action: {
                    do {
                        try Auth.auth().signOut()
                        authViewModel.isAuthenticated = false
                        print("Successfully logged out user")
                    } catch {
                        print("Error signing out: \(error.localizedDescription)")
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 150, height: 50)
                            .foregroundStyle(Color("ValtRed"))
                        
                        Text("Log Out")
                            .font(.custom("OpenSans-Bold", size: 19))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AppBackgroundColor"))
    }
}
