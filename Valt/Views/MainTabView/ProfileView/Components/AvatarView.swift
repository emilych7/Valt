import SwiftUI

struct AvatarView: View {
    let loadingState: ContentLoadingState
    let profileImage: UIImage?
    
    var body: some View {
        ZStack {
            switch loadingState {
            case .loading:
                Ellipse()
                    .frame(width: 85, height: 85)
                    .foregroundColor(Color("BubbleColor"))
                    .overlay(ProgressView().frame(width: 25, height: 25))
                    
            case .empty, .error:
                placeholderView
                
            case .complete:
                if let uiImage = profileImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 85, height: 85)
                        .clipShape(Ellipse())
                } else {
                    placeholderView
                }
            }
        }
    }
    
    private var placeholderView: some View {
        Ellipse()
            .frame(width: 85, height: 85)
            .foregroundColor(Color("BubbleColor"))
            .overlay(
                Image(systemName: "camera.fill")
                    .foregroundColor(Color("TextColor"))
                    .font(.system(size: 20))
            )
    }
}
