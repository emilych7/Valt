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
                    Text(userViewModel.username)
                        .font(.custom("OpenSans-SemiBold", size: 21))
                    
                    Text("\(userViewModel.followerCount) followers")
                    
                    HStack(spacing: 10) {
                        Text("\(userViewModel.draftCount) drafts")
                        
                        Circle()
                            .fill(Color("TextColor"))
                            .frame(width: 3, height: 3)
                        
                        Text("\(userViewModel.publishedDraftCount) published")
                    }
                }
                .font(.custom("OpenSans-Regular", size: 15))
                .padding(.horizontal, 5)
                .foregroundColor(Color("TextColor"))
            
            case .error, .empty:
                Text(userViewModel.userLoadingState == .empty ? "No user data" : "Error loading...")
                    .foregroundColor(.valtRed)
            
        }
        
    }
}

