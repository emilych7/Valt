import SwiftUI

struct MainHeader: View {
    let title: String
    var image1: String? = nil
    var action1: (() -> Void)? = nil
    var image2: String? = nil
    var action2: (() -> Void)? = nil
    
    init(
        title: String,
        image1: String? = nil,
        action1: (() -> Void)? = nil,
        image2: String? = nil,
        action2: (() -> Void)? = nil
    ) {
        self.title = title
        self.image1 = image1
        self.action1 = action1
        self.image2 = image2
        self.action2 = action2
    }
    
    init(
        title: String,
        image: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.image1 = nil
        self.action1 = nil
        self.image2 = image
        self.action2 = action
    }
    
    private var hasLeading: Bool {
        image1 != nil && action1 != nil
    }
    
    private var hasTrailing: Bool {
        image2 != nil && action2 != nil
    }
    
    var body: some View {
        HStack(spacing: 0) {
            if let imageName1 = image1, let buttonAction1 = action1 {
                headerButton(imageName: imageName1, action: buttonAction1)
            } else if hasTrailing {
                Color.clear
                    .frame(width: 40, height: 40)
            }
            
            Spacer()
            
            Text(title)
                .font(.custom("OpenSans-SemiBold", size: 24))
                .foregroundColor(Color("TextColor"))
                .multilineTextAlignment(.center)
                .lineLimit(1)
            
            Spacer()
            
            if let imageName2 = image2, let buttonAction2 = action2 {
                headerButton(imageName: imageName2, action: buttonAction2)
            } else if hasLeading {
                Color.clear
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 20)
        .padding(.bottom, 15)
        .background(Color("AppBackgroundColor"))
    }
    
    @ViewBuilder
    private func headerButton(imageName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Ellipse()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color("BubbleColor"))
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview("Two Buttons (Leading & Trailing)") {
    MainHeader(
        title: "Two Buttons",
        image1: "exitIcon",
        action1: { print("Leading Action") },
        image2: "settingsIcon",
        action2: { print("Trailing Action") }
    )
}

#Preview("Single Trailing Button") {
    MainHeader(
        title: "My Valt",
        image: "settingsIcon",
        action: { print("Settings") }
    )
}
