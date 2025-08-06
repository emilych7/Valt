import SwiftUI

@MainActor
struct HomeView: View {
    @FocusState private var isTextFieldFocused: Bool
    @EnvironmentObject private var userViewModel: UserViewModel
    @StateObject private var viewModel: HomeViewModel
    
    @State private var hasFocusedOnce = false
    @State private var keyboardVisible = false
    
    init(userViewModel: UserViewModel) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(userViewModel: userViewModel))
    }

    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Spacer()
                viewModel.button(icon: viewModel.isFavorited ? "Favorite-Active" : "Favorite-Inactive") {
                    withAnimation { viewModel.isFavorited.toggle() }
                }
                viewModel.button(icon: "saveIcon") {
                    withAnimation {
                        viewModel.saveDraftToFirebase()
                        dismissKeyboardSmoothly()
                    }
                }
                viewModel.button(icon: "moreIcon") {
                    withAnimation { viewModel.showMoreOptions.toggle() }
                }
                .popover(isPresented: $viewModel.showMoreOptions) {
                    MoreOptionsView(
                        selection: $viewModel.selectedMoreOption,
                        options: [MoreOption.publish, MoreOption.hide]
                    ) { option in
                        switch option {
                        case .publish:
                            print("Publish option selected.")
                        case .hide:
                            print("Hide option selected.")
                        default:
                            break
                        }
                        viewModel.selectedMoreOption = nil
                        viewModel.showMoreOptions = false
                    }
                    .presentationCompactAdaptation(.popover)
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            ZStack(alignment: .topLeading) {
                if viewModel.draftText.isEmpty && !isTextFieldFocused {
                    Text("Start your draft here")
                        .font(.custom("OpenSans-Regular", size: 16))
                        .foregroundColor(Color("TextColor").opacity(0.4))
                        .padding(.top, 12)
                        .padding(.leading, 10)
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
        
        // Toolbar above the keyboard
        .safeAreaInset(edge: .bottom) {
            if isTextFieldFocused {
                HStack {
                    Button("Clear") {
                        viewModel.draftText = ""
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal, 15)
                    
                    Spacer()
                    
                    Button {
                        dismissKeyboardSmoothly()
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .foregroundColor(Color("TextColor"))
                    }
                    .padding(.horizontal, 15)
                    
                    Spacer()
                    
                    Button("Save") {
                        viewModel.saveDraftToFirebase()
                        dismissKeyboardSmoothly()
                    }
                    .foregroundColor(Color("TextColor"))
                    .padding(.horizontal, 15)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color("TextFieldBackground").ignoresSafeArea())
                .transition(.move(edge: .bottom))
                .animation(.easeInOut(duration: 0.25), value: isTextFieldFocused)
            }
        }
        
        // Auto-focus to fix first-tap issue
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if !hasFocusedOnce {
                    isTextFieldFocused = true
                    hasFocusedOnce = true
                }
            }
        }
    }
    
    // Smooth keyboard dismiss
    func dismissKeyboardSmoothly() {
        DispatchQueue.main.async {
            isTextFieldFocused = false
        }
    }
}
