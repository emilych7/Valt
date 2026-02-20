import SwiftUI

struct MoreOptionsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selection: MoreOption?
    var options: [MoreOption] = MoreOption.allCases
    var onSelect: (MoreOption) -> Void
    
    let rows = [GridItem(.flexible(minimum: 150), spacing: 3)]
    
    var body: some View {
        LazyVGrid(columns: rows, spacing: 0) {
            ForEach(options) { moreOption in
                    Button {
                        selection = moreOption
                        onSelect(moreOption)
                        withAnimation {
                            dismiss()
                        }
                    } label: {
                            Text(moreOption.rawValue)
                                .foregroundColor(Color("TextColor"))
                                .font(.custom("OpenSans-Regular", size: 17))
                            
                            Spacer()
                        
                            Image(moreOption.imageName)
                                .resizable()
                                .frame(width: 20, height: 20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)

                    if moreOption.id != options.last?.id {
                        Divider()
                            .background(Color("TextColor").opacity(0.2))
                    }
                }
        }
        .background(Color("TextFieldBackground"))
        .fixedSize()
    }
}
