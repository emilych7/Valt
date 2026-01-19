import SwiftUI

struct AuthInputField<T: Hashable>: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    var field: T
    var focusState: FocusState<T?>.Binding
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text(title)
                    .font(.custom("OpenSans-Regular", size: 17))
                    .foregroundColor(Color("TextColor"))
                Spacer()
            }
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 50)
                    .foregroundColor(Color("TextFieldBackground"))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("TextFieldBorder"), lineWidth: 1))
                
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                            .textContentType(.oneTimeCode) // Prevents hang
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                    }
                }
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .padding(.horizontal)
                .focused(focusState, equals: field)
            }
        }
        .padding(.vertical, 5)
    }
}

struct AuthActionButton: View {
    let title: String
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Color("RequestButtonColor"))
                    .cornerRadius(12)
            } else {
                Button(action: action) {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.custom("OpenSans-Bold", size: 20))
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(Color("RequestButtonColor"))
                        .cornerRadius(12)
                }
                .disabled(isDisabled)
                .opacity(isDisabled ? 0.5 : 1.0)
            }
        }
        .padding(.top, 15)
    }
}
