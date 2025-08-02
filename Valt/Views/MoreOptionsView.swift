import SwiftUI

struct MoreOptionsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selection: MoreOption?
    @State private var isSelected: Bool = false

    let rows = [GridItem(.adaptive(minimum: 100), spacing: 3)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: rows) {
                ForEach(MoreOption.allCases) { moreOption in
                    Button(action: {
                        withAnimation {
                            selection = moreOption
                        }
                        // dismiss()
                    }) {
                        HStack(spacing: 10) {
                            Image("checkmarkIcon")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .opacity(selection == moreOption ? 1 : 0)

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
        .padding(.vertical, 20)
        .background(Color("AppBackgroundColor"))
    }
}

