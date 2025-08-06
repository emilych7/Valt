import SwiftUI

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
            // --- Header Buttons (same as before)
            headerButtons
            
            // --- Draft Editor
            ZStack(alignment: .topLeading) {
                if viewModel.draftText.isEmpty && !isTextFieldFocused {
                    Text("Start your draft here")
                        .font(.custom("OpenSans-Regular", size: 17))
                        .foregroundColor(Color("TextColor").opacity(0.3))
                        .padding(.top, 12)
                        .padding(.leading, 10)
                }

                TextEditor(text: $viewModel.draftText)
                    .font(.custom("OpenSans-Regular", size: 17))
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
        
        // MARK: - Full-width Toolbar above Keyboard
        .safeAreaInset(edge: .bottom) {
            if isTextFieldFocused {
                HStack {
                    Button("Clear") {
                        viewModel.draftText = ""
                    }
                    .foregroundColor(.red)
                    
                    Spacer()
                    
                    Button {
                        dismissKeyboardSmoothly()
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .foregroundColor(Color("TextColor"))
                    }
                    
                    Spacer()
                    
                    Button("Save") {
                        viewModel.saveDraftToFirebase()
                        dismissKeyboardSmoothly()
                    }
                    .foregroundColor(Color("TextColor"))
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color("TextFieldBackground").ignoresSafeArea())
                .transition(.move(edge: .bottom))
                .animation(.easeInOut(duration: 0.25), value: isTextFieldFocused)
            }
        }
        
        // Auto-focus once on appear to fix first-tap issue
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if !hasFocusedOnce {
                    isTextFieldFocused = true
                    hasFocusedOnce = true
                }
            }
        }
    }
    
    // MARK: - Header Buttons
    private var headerButtons: some View {
        HStack(spacing: 10) {
            Spacer()
            button(icon: viewModel.isFavorited ? "Favorite-Active" : "Favorite-Inactive") {
                withAnimation { viewModel.isFavorited.toggle() }
            }
            button(icon: "saveIcon") {
                withAnimation {
                    viewModel.saveDraftToFirebase()
                    dismissKeyboardSmoothly()
                }
            }
            button(icon: "moreIcon") {
                withAnimation { viewModel.showMoreOptions.toggle() }
            }
            .popover(isPresented: $viewModel.showMoreOptions) {
                MoreOptionsView(selection: $viewModel.selectedMoreOption) { option in
                    if option == .edit { viewModel.showMoreOptions = false }
                }
                .presentationCompactAdaptation(.popover)
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 20)
    }
    
    // MARK: - Helper Buttons
    private func button(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Ellipse()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color("BubbleColor"))
                Image(icon)
                    .frame(width: 38, height: 38)
                    .opacity(icon.contains("Inactive") ? 0.5 : 1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Smooth Keyboard Dismiss
    private func dismissKeyboardSmoothly() {
        DispatchQueue.main.async {
            isTextFieldFocused = false
        }
    }
}
