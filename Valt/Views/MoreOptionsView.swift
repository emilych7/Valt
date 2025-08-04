import SwiftUI

struct MoreOptionsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selection: MoreOption?
    @State private var isSelected: Bool = false
    var onSelect: (MoreOption) -> Void

    let rows = [GridItem(.flexible(minimum: 100), spacing: 3)]
    
    var body: some View {
        ZStack {
            LazyVGrid(columns: rows) {
                ForEach(MoreOption.allCases) { moreOption in
                    Button(action: {
                        withAnimation {
                            selection = moreOption
                            onSelect(moreOption) // notifying parent FullNoteView
                        }
                    }) {
                        HStack (spacing: 5) {
                            Image(moreOption.imageName)
                                .resizable()
                                .frame(width: 20, height: 20)
                            
                            Text(moreOption.rawValue)
                                .foregroundColor(Color("TextColor"))
                                .font(.custom("OpenSans-Regular", size: 17))
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(width: 130, height: 170)
        .background(Color("AppBackgroundColor"))
    }
}
