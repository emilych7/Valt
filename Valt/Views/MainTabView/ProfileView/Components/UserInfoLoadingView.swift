import SwiftUI

struct UserInfoLoadingView: View {
    var body: some View {
        skeletonRow(text: "@username", font: .custom("OpenSans-SemiBold", size: 21))
        skeletonRow(text: "-- drafts", font: .custom("OpenSans-Regular", size: 15))
        skeletonRow(text: "-- published", font: .custom("OpenSans-Regular", size: 15))
    }
    
    private func skeletonRow(text: String, font: Font) -> some View {
        Text(text)
            .font(font)
            .padding(.horizontal, 5)
            .padding(.top, 2)
            .opacity(0) // Hide text, keep space
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("BubbleColor"))
                    .shimmer()
            )
    }
}
