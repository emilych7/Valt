import SwiftUI

struct MoreOptionsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selection: MoreOption?
    @State private var isSelected: Bool = false

    let rows = [GridItem(.adaptive(minimum: 100), spacing: 3)]
    
    var body: some View {
        LazyVGrid(columns: rows) {
                ForEach(MoreOption.allCases) { option in
                    Button(action: {
                        withAnimation {
                            selection = option
                        }
                        // dismiss()
                    }) {
                        HStack (spacing: 5) {
                            Image("checkmarkIcon")
                                .frame(width: 15, height: 15)
                            
                            Text(option.rawValue)
                            // .background(selection == filter ? Color.blue : Color.gray)
                                .foregroundColor(Color("TextColor"))
                                .font(.custom("OpenSans-Regular", size: 17))
                            
                            Spacer()
                        }
                    }
                }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color("AppBackgroundColor"))
    }
}
