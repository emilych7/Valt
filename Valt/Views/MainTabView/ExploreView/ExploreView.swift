import SwiftUI

struct ExploreView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                MainHeader(title: "Explore")
                
                Spacer()
            }
            .background(
                ZStack {
                    Color("AppBackgroundColor")
                    Color("TextFieldBackground").opacity(0.7)
                }
                .ignoresSafeArea()
            )
        }
    }
}
