import SwiftUI

struct SkeletonCardView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color("TextFieldBackground"))
            .aspectRatio(0.7, contentMode: .fit)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("TextColor").opacity(0.1), lineWidth: 1)
            )
            .shimmer()
    }
}
