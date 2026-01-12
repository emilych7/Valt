import SwiftUI

struct ActivityView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                headerSection
                    .padding(.top, 15)
                    .background(Color("AppBackgroundColor"))
                
                ScrollView {
                    VStack(spacing: 20) {
                        interactionSection
                        archiveSection
                        timeSection
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
        }
        .background(Color("AppBackgroundColor").ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    private var headerSection: some View {
        HStack {
            Text("Activity")
                .font(.custom("OpenSans-SemiBold", size: 24))
                .foregroundColor(Color("TextColor"))
            
            Spacer()
            
            Button { dismiss() } label: {
                ZStack {
                    HStack (spacing: 5) {
                        Image("exitDynamicIcon")
                            .resizable()
                            .frame(width: 17, height: 17)
                        Text("Exit")
                            .foregroundColor(Color("TextColor"))
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                }
                .background(Color("BubbleColor"))
                .cornerRadius(12)
                
                
            }
        }
        .padding(.horizontal, 25)
        .padding(.bottom, 15)
    }
    
    private var interactionSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Interactions")
            
            NavigationLink(destination: Text("Favorited Content")) { settingsRow(title: "Favorited") }
                .padding(.horizontal, 15)
                .font(.custom("OpenSans-SemiBold", size: 17))
            Divider()
                .frame(height: 1)
                .background(Color("TextFieldBorder"))
            
            
            NavigationLink(destination: Text("Published Content")) { settingsRow(title: "Published") }
                .padding(.horizontal, 15)
                .font(.custom("OpenSans-SemiBold", size: 17))
            Divider()
                .frame(height: 1)
                .background(Color("TextFieldBorder"))
            
            NavigationLink(destination: Text("Shared Content")) { settingsRow(title: "Shared") }
                .padding(.horizontal, 15)
                .font(.custom("OpenSans-SemiBold", size: 17))
        }
        .background(Color("TextFieldBackground"))
    }
    
    private var archiveSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Archived and Removed Content")
            NavigationLink(destination: Text("Recently Deleted")) { settingsRow(title: "Recently Deleted") }
                .padding(.horizontal, 15)
                .font(.custom("OpenSans-SemiBold", size: 17))
            
            Divider()
                .frame(height: 1)
                .background(Color("TextFieldBorder"))
            
            NavigationLink(destination: Text("Archived")) { settingsRow(title: "Archived") }
                .padding(.horizontal, 15)
                .font(.custom("OpenSans-SemiBold", size: 17))
        }
        .background(Color("TextFieldBackground"))
    }
    
    private var timeSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Account Management")
            NavigationLink(destination: Text("Deactivate Account")) {
                settingsRow(title: "Deactivate Account")
                    .padding(.horizontal, 15)
                    .font(.custom("OpenSans-SemiBold", size: 17))
            }
        }
        .background(Color("TextFieldBackground"))
    }
    
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.custom("OpenSans-SemiBold", size: 18))
            Spacer()
        }
        .padding([.horizontal, .top], 20)
        .padding(.bottom, 10)
    }

    private func settingsRow(title: String) -> some View {
        HStack {
            Text(title)
                .font(.custom("OpenSans-Regular", size: 17))
                .foregroundColor(Color("TextColor"))
            Spacer()
            Image("rightArrowIcon")
                .resizable()
                .frame(width: 14, height: 14)
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

#Preview("Logged In State") {
    let mockAuth = AuthViewModel()
    
    return ActivityView()
        .environmentObject(mockAuth)
}
