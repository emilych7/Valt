import SwiftUI

@MainActor
struct HomeView: View {
    @FocusState private var isTextFieldFocused: Bool
    
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @StateObject private var viewModel: HomeViewModel
    
    @State private var hasFocusedOnce = false
    @State private var keyboardVisible = false

    init(userViewModel: UserViewModel) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(userViewModel: userViewModel))
    }

    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 10) {
                    Spacer()
                    viewModel.button(icon: viewModel.isFavorited ? "Favorite-Active" : "Favorite-Inactive") {
                        withAnimation { viewModel.isFavorited.toggle() }
                    }
                    viewModel.button(icon: "saveIcon") {
                        if !viewModel.draftText.isEmpty {
                            viewModel.saveDraftToFirebase()
                            bannerManager.show("Saved Draft")
                        } else {
                            print("Draft is empty. Not saving.")
                        }
                        dismissKeyboardSmoothly()
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)
                
                ZStack(alignment: .topLeading) {
                    switch viewModel.draftLoadingState {
                    case .loading:
                        HStack {
                            Spacer()
                            ProgressView()
                                .foregroundColor(Color("TextColor"))
                                .frame(width: 40, height: 40)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        
                    default:
                        if viewModel.draftText.isEmpty && !isTextFieldFocused {
                            Text("Start your draft here")
                                .font(.custom("OpenSans-Regular", size: 16))
                                .foregroundColor(Color("TextColor").opacity(0.4))
                        }
                    }
                    
                    TextEditor(text: $viewModel.draftText)
                        .font(.custom("OpenSans-Regular", size: 16))
                        .foregroundColor(Color("TextColor"))
                        .scrollContentBackground(.hidden)
                        .focused($isTextFieldFocused)
                        .onTapGesture {
                            isTextFieldFocused = true
                            hasFocusedOnce = true
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("AppBackgroundColor"))
                .cornerRadius(10)
                .padding(.bottom, 20)
                .padding(.horizontal, 25)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("AppBackgroundColor"))
        }
        .safeAreaInset(edge: .bottom) {
            if isTextFieldFocused {
                HStack {
                    Button("Clear") {
                        viewModel.draftText = ""
                        bannerManager.show("Cleared")
                    }
                    .foregroundColor(.red)
                    .font(.custom("OpenSans-Regular", size: 17))
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    Button {
                        dismissKeyboardSmoothly()
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .resizable()
                            .foregroundColor(Color("TextColor"))
                            .frame(width: 25, height: 20)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    Button("Save") {
                        if !viewModel.draftText.isEmpty {
                            viewModel.saveDraftToFirebase()
                            bannerManager.show("Saved Draft")
                        } else {
                            print("Draft is empty. Not saving.")
                            bannerManager.show("Empty Draft")
                        }
                        dismissKeyboardSmoothly()
                    }
                    .foregroundColor(Color("TextColor"))
                    .font(.custom("OpenSans-Regular", size: 17))
                    .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color("TextFieldBackground").ignoresSafeArea())
                .transition(.move(edge: .bottom))
                .animation(.easeInOut(duration: 0.10), value: isTextFieldFocused)
            }
        }
    }
    
    func dismissKeyboardSmoothly() {
        isTextFieldFocused = false
    }
}
