import SwiftUI

struct OtherUserView: View {
    @State var isBookmarked: Bool = false
    @EnvironmentObject var UserViewModel: UserViewModel
    
    var body: some View {
        VStack {
            MainHeader(title: "other_user", image: "bookmarkIcon")
            
            Text("Hello, world!")
            
            Spacer()
        }
    }
}

#Preview {
    OtherUserView()
}
