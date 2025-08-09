import SwiftUI
import FirebaseAuth

struct PromptsView: View {
    @StateObject private var viewModel = PromptsViewModel()

    var body: some View {
        VStack(spacing: 16) {
            // Title
            HStack {
                Text("PromptGen")
                    .font(.custom("OpenSans-SemiBold", size: 24))
                Spacer()
            }
            .padding(.horizontal, 25)
            .padding(.top, 20)

            // Search usernames
            VStack(spacing: 8) {
                HStack {
                    TextField("Search usernames…", text: $viewModel.searchText)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .font(.custom("OpenSans-Regular", size: 15))
                        .padding(10)
                        .background(Color("TextFieldBackground"))
                        .cornerRadius(10)
                        
                        // <- iOS 14+ signature so it fires on all supported OS versions
                        .onChange(of: viewModel.searchText) {
                            viewModel.onSearchTextChanged()
                        }
                }
                .padding(.horizontal, 20)

                // Suggestions list
                if !viewModel.usernameSuggestions.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(viewModel.usernameSuggestions, id: \.self) { name in
                                Button {
                                    viewModel.loadPublishedDrafts(for: name)
                                    viewModel.usernameSuggestions = []
                                    viewModel.searchText = name
                                } label: {
                                    HStack {
                                        Text(name)
                                            .foregroundColor(Color("TextColor"))
                                            .font(.custom("OpenSans-Regular", size: 15))
                                        Spacer()
                                        if viewModel.selectedUsername == name {
                                            Image(systemName: "checkmark.circle.fill")
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                }
                                .buttonStyle(.plain)

                                if name != viewModel.usernameSuggestions.last {
                                    Divider()
                                        .background(Color("TextFieldBorder").opacity(0.6))
                                }
                            }
                        }
                        .background(Color("TextFieldBackground"))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("TextFieldBorder"), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                    }
                    .frame(maxHeight: 180)
                    .background(Color("BorderColor"))
                }
            }

            Spacer()

            // Generated prompt box
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("TextFieldBackground"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("TextFieldBorder"), lineWidth: 1)
                        )

                    Text(viewModel.generatedPrompt)
                        .font(.custom("OpenSans-Regular", size: 15))
                        .foregroundColor(Color("TextColor"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: 90)
            }
            .padding(.horizontal, 20)

            // Action buttons
            HStack(spacing: 15) {
                Button {
                    // Navigate to your writing view if needed
                } label: {
                    HStack(spacing: 10) {
                        Text("Start Writing")
                            .font(.custom("OpenSans-SemiBold", size: 15))
                            .foregroundColor(.white)
                        Image("Write")
                            .frame(width: 15, height: 15)
                    }
                }
                .frame(height: 45)
                .frame(maxWidth: .infinity)
                .background(Color("RequestButtonColor"))
                .cornerRadius(12)

                Button {
                    viewModel.generatePromptFromOwnDrafts()
                } label: {
                    HStack(spacing: 10) {
                        Text("New Prompt")
                            .font(.custom("OpenSans-SemiBold", size: 15))
                            .foregroundColor(.white)
                        Image("Refresh")
                            .frame(width: 15, height: 15)
                    }
                }
                .frame(height: 45)
                .frame(maxWidth: .infinity)
                .background(Color("RequestButtonNeutral"))
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)

            if let selected = viewModel.selectedUsername {
                Button {
                    viewModel.generatePromptFromPublishedDraftsForSelectedUser()
                } label: {
                    Text("Use \(selected)’s published drafts")
                        .font(.custom("OpenSans-SemiBold", size: 15))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 45)
                        .background(Color("RequestButtonNeutral"))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
            }

            Spacer()
        }
        .background(Color("AppBackgroundColor"))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    PromptsView()
}
