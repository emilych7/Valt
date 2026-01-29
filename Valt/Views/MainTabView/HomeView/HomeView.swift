import SwiftUI

@MainActor
struct HomeView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @State private var showNewNote = false
    
    var body: some View {
        VStack {
            Button("New Note") {
                showNewNote = true
            }
            .fullScreenCover(isPresented: $showNewNote) {
                NewNote(userViewModel: userViewModel)
            }
        }
        .background(Color("TextFieldBackground"))
    }
}
