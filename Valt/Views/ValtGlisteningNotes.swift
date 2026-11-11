import SwiftUI

struct ValtGlisteningNotes: View {
    var size: CGFloat = 220
    var isActive: Bool = true

    var body: some View {
        ValtTiltCardsView(size: size, isActive: isActive)
    }
}
