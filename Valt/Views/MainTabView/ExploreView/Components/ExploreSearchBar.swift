import SwiftUI

struct ExploreSearchBar: View {
    @Binding var searchText: String
    @Binding var isFocused: Bool
    @Binding var searchScope: ExploreSearchScope
    let placeholder: String
    let onSearchChanged: () -> Void
    let onCancel: () -> Void
    
    @FocusState private var fieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(fieldFocused ? Color("TextColor") : Color("TextColor").opacity(0.5))
                        .animation(.easeInOut(duration: 0.2), value: fieldFocused)
                    
                    TextField(placeholder, text: $searchText)
                        .focused($fieldFocused)
                        .font(.custom("OpenSans-Regular", size: 15))
                        .foregroundColor(Color("TextColor"))
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .onChange(of: searchText) { _, newValue in
                            if newValue.count > 30 {
                                searchText = String(newValue.prefix(30))
                            }
                            onSearchChanged()
                        }
                    
                    if !searchText.isEmpty {
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.prepare()
                            generator.impactOccurred()
                            searchText = ""
                            onSearchChanged()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color("TextColor").opacity(0.5))
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 46)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color("TextFieldBackground"))
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(
                                    fieldFocused ?
                                    Color("TextColor").opacity(0.35) :
                                    Color("TextColor").opacity(0.12),
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: Color.black.opacity(fieldFocused ? 0.08 : 0.03),
                            radius: 8,
                            x: 0,
                            y: 3
                        )
                )
                
                if fieldFocused || !searchText.isEmpty {
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.prepare()
                        generator.impactOccurred()
                        fieldFocused = false
                        isFocused = false
                        searchText = ""
                        onCancel()
                    } label: {
                        Text("Cancel")
                            .font(.custom("OpenSans-SemiBold", size: 15))
                            .foregroundColor(Color("TextColor"))
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.32, dampingFraction: 0.82), value: fieldFocused)
            .animation(.spring(response: 0.32, dampingFraction: 0.82), value: searchText.isEmpty)
            
            if fieldFocused || !searchText.isEmpty {
                HStack(spacing: 8) {
                    ForEach(ExploreSearchScope.allCases) { scope in
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.prepare()
                            generator.impactOccurred()
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                                searchScope = scope
                            }
                        } label: {
                            Text(scope.rawValue)
                                .font(.custom("OpenSans-SemiBold", size: 13))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(searchScope == scope ? Color("TextColor") : Color("BubbleColor"))
                                )
                                .foregroundColor(searchScope == scope ? Color("ReverseTextColor") : Color("TextColor").opacity(0.8))
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .onChange(of: isFocused) { _, newValue in
            fieldFocused = newValue
        }
        .onChange(of: fieldFocused) { _, newValue in
            isFocused = newValue
        }
    }
}
