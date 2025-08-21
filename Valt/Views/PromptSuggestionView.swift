import SwiftUI

struct PromptSuggestionView: View {
    let prompt: String

    var body: some View {
        ZStack {
            // Text content
            Text(prompt)
                .font(.custom("OpenSans-Regular", size: 17))
                .foregroundColor(Color("TextColor"))
                .lineLimit(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 60)   
                .padding(.vertical, 10)
                .padding(.trailing, 10)
        }
        // Pin the icon to a fixed spot
        .overlay(alignment: .topLeading) {
            Image("editIcon")
                .resizable()
                .frame(width: 25, height: 25)
                .padding(.top, 15)
                .padding(.leading, 15)
        }
        .frame(maxWidth: .infinity, minHeight: 70, alignment: .topLeading)
    }
}
