import SwiftUI
import FirebaseAuth

struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()

    var body: some View {
        VStack(spacing: 15) {
            // Title
            HStack {
                Text("Find a Prompt")
                    .font(.custom("OpenSans-SemiBold", size: 24))
                Spacer()
            }
            .padding(.horizontal, 25)
            .padding(.top, 20)

            // Search usernames
            VStack(spacing: 8) {
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("TextFieldBackground"))
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color("TextFieldBorder"), lineWidth: 1)
                            )
                        
                        HStack (spacing: 8) {
                            Image("searchIcon")
                                .resizable()
                                .frame(width: 15, height: 15)
                            
                            TextField("Search for a username", text: $viewModel.searchText)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .font(.custom("OpenSans-Regular", size: 17))
                                .foregroundColor(Color("TextColor"))
                            
                            // <- iOS 14+ signature
                                .onChange(of: viewModel.searchText) {
                                    viewModel.onSearchTextChanged()
                                }
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 5)
                    }
                }
                .padding(.horizontal, 25)

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
            if !viewModel.publishedDraftsForUser.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.publishedDraftsForUser) { draft in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(draft.title)
                                    .font(.custom("OpenSans-SemiBold", size: 16))
                                    .foregroundColor(Color("TextColor"))
                                
                                Text(draft.content)
                                    .font(.custom("OpenSans-Regular", size: 14))
                                    .foregroundColor(Color("TextColor").opacity(0.8))
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxHeight: 250) // Adjust height as needed
            }

            Spacer()
            
            HStack {
                Text("Suggestions")
                    .font(.custom("OpenSans-SemiBold", size: 20))
                    .foregroundColor(Color("TextColor"))
                
                Spacer()
                
            }
            .padding(.horizontal, 25)
            
            // Generated prompt box
            HStack {
                ZStack {
                    let shell = RoundedRectangle(cornerRadius: 12)

                    shell
                        .fill(Color("TextFieldBackground"))
                        .overlay(shell.stroke(Color("TextFieldBorder"), lineWidth: 1))

                    GeometryReader { geo in
                        // Inner padding must match below
                        let innerPad: CGFloat = 10
                        let rowCount = 5
                        let rowHeight = max(0, (geo.size.height - innerPad * 2) / CGFloat(rowCount))

                        VStack(spacing: 0) {
                            ForEach(0..<rowCount, id: \.self) { i in
                                PromptSuggestionView(prompt: viewModel.generatedPrompt)
                                    .frame(height: rowHeight, alignment: .topLeading)
                            }
                        }
                        .padding(innerPad)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                    .clipShape(shell)
                }
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal, 25)
            .padding(.bottom, 10)

            // Action buttons
            HStack(spacing: 15) {
                Button {
                    viewModel.generatePromptFromOwnDrafts()
                } label: {
                    HStack(spacing: 10) {
                        Text("Generate Prompts")
                            .font(.custom("OpenSans-SemiBold", size: 18))
                            .foregroundColor(.white)
                        Image("Refresh")
                            .frame(width: 17, height: 17)
                    }
                }
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(Color("RequestButtonColor"))
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            /*
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
            */

            Spacer()
        }
        .background(Color("AppBackgroundColor"))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ExploreView()
}
