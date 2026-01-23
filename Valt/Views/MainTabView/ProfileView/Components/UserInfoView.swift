import SwiftUI

struct UserInfoView: View {
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        switch userViewModel.userLoadingState {
            case .loading:
                VStack(alignment: .leading, spacing: 5) {
                UserInfoLoadingView()
                    .shimmer()
                    .transition(.opacity)
                }
                .font(.custom("OpenSans-Regular", size: 15))
                .padding(.horizontal, 5)
                .foregroundColor(Color("TextColor"))
            
            case .complete:
                VStack(alignment: .leading, spacing: 5) {
                    Text(userViewModel.username)
                        .font(.custom("OpenSans-SemiBold", size: 21))
                    Text("\(userViewModel.draftCount) drafts")
                    Text("\(userViewModel.publishedDraftCount) published")
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

