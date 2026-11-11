import SwiftUI

struct AuthInputField<T: Hashable>: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var field: T
    var focusState: FocusState<T?>.Binding
    var borderColor: String = "TextColor"
    
    @State private var isPasswordVisible: Bool = false
    
    private var isFocused: Bool {
        focusState.wrappedValue == field
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom("OpenSans-SemiBold", size: 14))
                .foregroundColor(Color("TextColor").opacity(0.85))
                .padding(.horizontal, 6)
            
            HStack(spacing: 12) {
                Group {
                    if isSecure && !isPasswordVisible {
                        SecureField(placeholder, text: $text)
                            .textContentType(.oneTimeCode)
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                    }
                }
                .font(.custom("OpenSans-Regular", size: 15))
                .foregroundColor(Color("TextColor"))
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .focused(focusState, equals: field)
                
                if isSecure && !text.isEmpty {
                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color("TextColor").opacity(0.55))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
            .frame(height: 50)
            .background(
                Capsule(style: .continuous)
                    .fill(Color("TextFieldBackground"))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(strokeColor, lineWidth: strokeWidth)
                    )
                    .shadow(
                        color: Color.black.opacity(isFocused ? 0.08 : 0.03),
                        radius: 8,
                        x: 0,
                        y: 3
                    )
            )
        }
        .padding(.vertical, 4)
        .animation(.spring(response: 0.28, dampingFraction: 0.85), value: isFocused)
    }
    
    private var strokeColor: Color {
        if borderColor == "ValtRed" {
            return Color("ValtRed")
        }
        return isFocused ? Color("TextColor").opacity(0.35) : Color("TextColor").opacity(0.12)
    }
    
    private var strokeWidth: CGFloat {
        if borderColor == "ValtRed" {
            return 1.5
        }
        return isFocused ? 1.2 : 1.0
    }
}

struct AuthActionButton: View {
    let title: String
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            guard !isDisabled && !isLoading else { return }
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
            action()
        }) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.custom("OpenSans-Bold", size: 16))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                Capsule(style: .continuous)
                    .fill(Color("RequestButtonColor"))
                    .opacity(isDisabled ? 0.45 : 1.0)
                    .shadow(
                        color: Color("RequestButtonColor").opacity(isDisabled ? 0 : 0.25),
                        radius: 8,
                        x: 0,
                        y: 3
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading)
        .padding(.vertical, 6)
        .animation(.spring(response: 0.28, dampingFraction: 0.85), value: isDisabled)
        .animation(.spring(response: 0.28, dampingFraction: 0.85), value: isLoading)
    }
}
