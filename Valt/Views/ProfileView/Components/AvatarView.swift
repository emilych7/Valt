import SwiftUI

struct AvatarView: View {
    let loadingState: ContentLoadingState
    let profileImage: UIImage?
    
    var body: some View {
        ZStack {
            switch loadingState {
            case .loading:
                Ellipse()
                    .frame(width: 105, height: 105)
                    .foregroundColor(Color("BubbleColor"))
                    .overlay(ProgressView().frame(width: 25, height: 25))
                    
            case .empty, .error:
                placeholderView
                
            case .complete:
                if let uiImage = profileImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 105, height: 105)
                        .clipShape(Ellipse())
                } else {
                    placeholderView
                }
            }
        }
        .frame(width: 115, height: 115)
    }
    
    private var placeholderView: some View {
        Ellipse()
            .frame(width: 105, height: 105)
            .foregroundColor(Color("BubbleColor"))
            .overlay(
                Image(systemName: "camera.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 24))
            )
    }
}
