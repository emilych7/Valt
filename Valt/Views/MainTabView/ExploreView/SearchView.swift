import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: ExploreViewModel
    
    var body: some View {
        VStack {
            Text("No users found")
                .foregroundColor(.gray)
                .padding(.top, 20)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(10)
        .padding(.horizontal, 20)
    }
}
