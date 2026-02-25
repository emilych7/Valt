import SwiftUI

struct PinEntryView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTab: ProfileTab
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 15) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 30))
                    .foregroundColor(Color("TextColor"))
                    .modifier(ShakeEffect(animatableData: CGFloat(userViewModel.shakeAttempts)))
                    .animation(.default, value: userViewModel.shakeAttempts)
                
                Spacer()
                
                Text("Enter PIN")
                    .font(.custom("OpenSans-SemiBold", size: 22))
                    .foregroundColor(Color("TextColor"))
                
                Text("Your PIN is required to view Hidden drafts")
                    .font(.custom("OpenSans-Regular", size: 14))
                    .foregroundColor(Color("TextColor").opacity(0.7))
            }
            .padding(.top, 40)
            
            Spacer()
            // Dots indicator
            HStack(spacing: 20) {
                ForEach(0..<userViewModel.maxDigits, id: \.self) { index in
                    Circle()
                        .stroke(Color(userViewModel.pinColor), lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .background(
                            Circle()
                                .fill(userViewModel.enteredPin.count > index ? Color(userViewModel.pinColor) : Color.clear)
                        )
                        .scaleEffect(userViewModel.enteredPin.count > index ? 1.1 : 1.0)
                        .animation(.spring(response: 0.2), value: userViewModel.enteredPin.count)
                        .modifier(ShakeEffect(animatableData: CGFloat(userViewModel.shakeAttempts)))
                        .animation(.default, value: userViewModel.shakeAttempts)
                }
            }
            
            Spacer()
            // Custom keypad
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                ForEach(1...9, id: \.self) { number in
                    keyButton("\(number)")
                }
                
                Color.clear // Spacer
                keyButton("0")
                
                // Delete Button
                Button {
                    if !userViewModel.enteredPin.isEmpty {
                        userViewModel.enteredPin.removeLast()
                    }
                } label: {
                    Image(systemName: "delete.left")
                        .font(.title2)
                        .frame(width: 90, height: 90)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 40)
            
            HStack {
                Spacer()
                
                Button {
                    userViewModel.enteredPin = ""
                    selectedTab = .all
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundStyle(Color("TextColor"))
                        .font(.custom("OpenSans-SemiBold", size: 15))
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 10)
            .padding(.bottom, 60)
        }
        .background(Color("AppBackgroundColor").ignoresSafeArea())
    }

    private func keyButton(_ value: String) -> some View {
        Button {
            if userViewModel.enteredPin.count < userViewModel.maxDigits {
                userViewModel.enteredPin.append(value)
                userViewModel.checkPin(enteredPin: userViewModel.enteredPin)
            }
        } label: {
            Text(value)
                .font(.custom("OpenSans-SemiBold", size: 28))
                .frame(width: 80, height: 80)
                .background(Color("TextFieldBackground").opacity(0.5))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
