import SwiftUI

struct UserInfoView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        switch userViewModel.userLoadingState {
            case .loading:
                VStack(alignment: .leading, spacing: 5) {
                UserInfoLoadingView()
                    .transition(.opacity)
                }
                .font(.custom("OpenSans-Regular", size: 15))
                .padding(.horizontal, 5)
                .foregroundColor(Color("TextColor"))
            
            case .complete:
            VStack(alignment: .leading, spacing: 5) {
                    Text("\(userViewModel.username)")
                        .font(.custom("OpenSans-Bold", size: 15))
                    
                    HStack (spacing: 30) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("\(userViewModel.draftCount)")
                                .font(.custom("OpenSans-SemiBold", size: 15))
                            
                            Text("drafts")
                                .font(.custom("OpenSans-Regular", size: 13))
                        }
                        .font(.custom("OpenSans-Regular", size: 15))
                        
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("\(userViewModel.publishedDraftCount)")
                                .font(.custom("OpenSans-SemiBold", size: 15))
                            
                            Text("published")
                                .font(.custom("OpenSans-Regular", size: 13))
                        }
                        .font(.custom("OpenSans-Regular", size: 15))
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("\(userViewModel.followerCount)")
                                .font(.custom("OpenSans-SemiBold", size: 15))
                            
                            Text("followers")
                                .font(.custom("OpenSans-Regular", size: 13))
                        }
                        .font(.custom("OpenSans-Regular", size: 15))
                        
                        Spacer()
                    }
                }
                .foregroundColor(Color("TextColor"))
            
            case .error, .empty:
                Text(userViewModel.userLoadingState == .empty ? "No user data" : "Error loading...")
                    .foregroundColor(Color("ValtRed"))
            
        }
    }
}

#Preview("User Info - Complete") {
    UserInfoView()
        .padding()
        .background(Color("AppBackgroundColor"))
        .environmentObject(UserViewModel.preview)
}

#Preview("User Info - With Avatar") {
    HStack(spacing: 12) {
        Avatar(loadingState: .complete, profileImage: nil)
        UserInfoView()
        Spacer()
    }
    .padding(.horizontal, 25)
    .padding(.vertical, 15)
    .background(Color("AppBackgroundColor"))
    .environmentObject(UserViewModel.preview)
}

#Preview("User Info - Loading State") {
    let vm = UserViewModel(isStub: true)
    let _ = { vm.userLoadingState = .loading }()
    
    HStack(spacing: 12) {
        Avatar(loadingState: .loading, profileImage: nil)
        UserInfoView()
            .environmentObject(vm)
        Spacer()
    }
    .padding(.horizontal, 25)
    .padding(.vertical, 15)
    .background(Color("AppBackgroundColor"))
}

