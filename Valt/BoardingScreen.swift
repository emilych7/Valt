import SwiftUI

struct BoardingScreen: Identifiable {
    var id = UUID().uuidString
    var image: String
    var title: String
    var description: String
}

let title = "Valt"

var boardingScreens: [BoardingScreen] = [

    BoardingScreen(image: "screen1", title: title, description: "Description 1"),
    BoardingScreen(image: "screen2", title: title, description: "Description 2"),
    BoardingScreen(image: "screen3", title: title, description: "Description 3"),
]
