import SwiftUI

struct FilterOptionsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selection: Filter?
    @State private var isSelected: Bool = false

    let rows = [GridItem(.adaptive(minimum: 100), spacing: 3)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: rows) {
                ForEach(Filter.allCases) { filter in
                    Button(action: {
                        withAnimation {
                            selection = filter
                        }
                        // dismiss()
                    }) {
                        HStack(spacing: 10) {
                            Image("checkmarkIcon")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .opacity(selection == filter ? 1 : 0)

                            Text(filter.rawValue)
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
