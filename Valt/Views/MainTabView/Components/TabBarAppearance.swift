import SwiftUI
import UIKit

struct TabBarAppearance: ViewModifier {
    init() {
        let appearance = UITabBarAppearance()
        
        // Background + shadow
        appearance.backgroundColor = UIColor(Color("AppBackgroundColor"))
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        
        let boldFont = UIFont(name: "OpenSans-Bold", size: 10) ?? UIFont.systemFont(ofSize: 10, weight: .bold)
        
        // Selected State
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color("TextColor"))
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .font: boldFont,
            .foregroundColor: UIColor(Color("TextColor"))
        ]
        
        // Unselected State
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .font: boldFont,
            .foregroundColor: UIColor.systemGray
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func applyTabBarAppearance() -> some View {
        self.modifier(TabBarAppearance())
    }
}
