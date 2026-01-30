import SwiftUI

struct ProfileTabView: View {
    @Binding var selectedTab: ProfileTab
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            tabButton(image: "homeCardsIcon", tab: .all)
            tabButton(image: "favoriteIcon", tab: .favorited)
            tabButton(image: "publishIcon", tab: .published)
            tabButton(image: "hideIcon", tab: .hidden)
        }
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity)
        .background(Color("AppBackgroundColor"))
        .overlay(
            Rectangle()
                .fill(Color("TextColor").opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    @ViewBuilder
    private func tabButton(image: String, tab: ProfileTab) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 8) {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(selectedTab == tab ? Color("TextColor") : .gray)
                    .padding(.bottom, 2)
                
                ZStack {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 1)
                    
                    if selectedTab == tab {
                        Rectangle()
                            .fill(Color("TextColor"))
                            .frame(height: 1)
                            .padding(.horizontal, 20)
                            .matchedGeometryEffect(id: "underline", in: animation)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
