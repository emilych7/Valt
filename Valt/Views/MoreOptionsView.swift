import SwiftUI

struct MoreOptionsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selection: MoreOption?
    var options: [MoreOption] = MoreOption.allCases
    var onSelect: (MoreOption) -> Void
    
    let rows = [GridItem(.flexible(minimum: 100), spacing: 3)]
    
    var body: some View {
        LazyVGrid(columns: rows, spacing: 8) {
            ForEach(options) { moreOption in
                Button {
                    selection = moreOption
                    onSelect(moreOption)
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(moreOption.imageName)
                            .resizable()
                            .frame(width: 20, height: 20)
                        
                        Text(moreOption.rawValue)
                            .foregroundColor(Color("TextColor"))
                            .font(.custom("OpenSans-Regular", size: 17))
                        
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 8)
                    .frame(maxWidth: .infinity, minHeight: 35)
                    .cornerRadius(6)
                }
            }
        }
        .padding(12)
        .background(Color("AppBackgroundColor"))
        .cornerRadius(12)
        .fixedSize()
    }
}
