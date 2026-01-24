import SwiftUI

struct PromptGeneratorContainer: View {
    let prompts: [String]
    
    var body: some View {
        ZStack {
            let shell = RoundedRectangle(cornerRadius: 12)
            shell
                .fill(Color("TextFieldBackground"))
                .overlay(shell.stroke(Color("TextColor").opacity(0.50), lineWidth: 1))

            GeometryReader { geo in
                let innerPad: CGFloat = 10
                let rowHeight = max(0, (geo.size.height - innerPad * 2) / 5)

                VStack(spacing: 0) {
                    ForEach(prompts, id: \.self) { prompt in
                        PromptBox(prompt: prompt)
                            .frame(height: rowHeight, alignment: .topLeading)
                    }
                }
                .padding(innerPad)
            }
        }
        .padding(.horizontal, 25)
        .padding(.bottom, 10)
    }
}

struct PromptBox: View {
    let prompt: String

    var body: some View {
        ZStack {
            // Text content
            Text(prompt)
                .font(.custom("OpenSans-Regular", size: 15))
                .foregroundColor(Color("TextColor"))
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
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
