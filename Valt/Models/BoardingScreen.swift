import SwiftUI

struct BoardingScreen: Identifiable {
    var id = UUID().uuidString
    var image: String
    var title: String
    var subtitle: String
    var description: String
}

var boardingScreens: [BoardingScreen] = [
    BoardingScreen(
        image: "screen1",
        title: "Welcome to Valt",
        subtitle: "A Home For The Messy Mind",
        description: "Valt was created for people who have a lot of thought. Sometimes too much to write with pencil on paper or too important to risk losing. It needs to be safe to think honestly."
    ),
    BoardingScreen(
        image: "screen2",
        title: "Thought Synthesis",
        subtitle: "Can It Make Sense?",
        description: "You write some thoughts and save a draft. You save a few more. Valt creates prompts for you to help you make sense of your thoughts."
    ),
    BoardingScreen(
        image: "screen3",
        title: "Autonomy",
        subtitle: "We Love Autonomy",
        description: "Valt is your space. You can keep drafts private forever or publish them. See other people's thoughts, share them, repost them. Run the app without AI. It is your space."
    ),
]
