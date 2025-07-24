import SwiftUI

struct BoardingScreen: Identifiable {
    var id = UUID().uuidString
    var image: String
    var title: String
    var subtitle: String
    var description: String
}

var boardingScreens: [BoardingScreen] = [
    BoardingScreen(image: "screen1", title: "Welcome to Valt", subtitle: "A Safe Space for Your Deepest Thoughts", description: "Valt is your private vault. It’s a space to write without fear. No leaks. No judgment. Just you and your thoughts."),
    BoardingScreen(image: "screen2", title: "Write, Reflect, Grow", subtitle: "Let Your Mind Wander", description: "Create meaningful notes in Home. After 4 entries, Valt’s AI will generate custom prompts that help you dive even deeper."),
    BoardingScreen(image: "screen3", title: "Discreet & Personal", subtitle: "Your Thoughts. Locked Tight", description: "Only you can access your Valt. Notes stay encrypted and out of sight. Want extra privacy? AI doesn’t need to see it either."),
]
