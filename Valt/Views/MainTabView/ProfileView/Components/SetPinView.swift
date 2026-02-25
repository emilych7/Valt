import SwiftUI

struct SetPinView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTab: ProfileTab
    @State private var isConfirming = false
    
    var body: some View {
        if isConfirming {
            confirmNewPinView(isConfirming: $isConfirming, selectedTab: $selectedTab)
        } else {
            VStack(spacing: 40) {
                VStack(spacing: 15) {
                    Text("Create a PIN")
                        .font(.custom("OpenSans-SemiBold", size: 22))
                        .foregroundColor(Color("TextColor"))
                    
                    Text("Your PIN will be required to view Hidden drafts")
                        .font(.custom("OpenSans-Regular", size: 14))
                        .foregroundColor(Color("TextColor").opacity(0.7))
                }
                .padding(.top, 70)
                
                Spacer()
                // Dots indicator
                HStack(spacing: 20) {
                    ForEach(0..<userViewModel.maxDigits, id: \.self) { index in
                        Circle()
                            .stroke(Color(userViewModel.pinColor), lineWidth: 2)
                            .frame(width: 20, height: 20)
                            .background(
                                Circle()
                                    .fill(userViewModel.newPin.count > index ? Color(userViewModel.pinColor) : Color.clear)
                            )
                            .scaleEffect(userViewModel.newPin.count > index ? 1.1 : 1.0)
                            .animation(.spring(response: 0.2), value: userViewModel.newPin.count)
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
                        if !userViewModel.newPin.isEmpty {
                            userViewModel.newPin.removeLast()
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
                        userViewModel.newPin = ""
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
    }

    private func keyButton(_ value: String) -> some View {
        Button {
            if userViewModel.newPin.count < userViewModel.maxDigits {
                userViewModel.newPin.append(value)
                
                // Once 4 digits are hit, move to confirmation step
                if userViewModel.newPin.count == userViewModel.maxDigits {
                    withAnimation {
                        isConfirming = true
                    }
                }
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

struct confirmNewPinView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var isConfirming: Bool
    @Binding var selectedTab: ProfileTab
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 15) {
                Text("Verify your new PIN")
                    .font(.custom("OpenSans-SemiBold", size: 22))
                    .foregroundColor(Color("TextColor"))
                
                Text("Your PIN will be required to view Hidden drafts")
                    .font(.custom("OpenSans-Regular", size: 14))
                    .foregroundColor(Color("TextColor").opacity(0.7))
            }
            .padding(.top, 70)
            
            Spacer()
            // Dots indicator
            HStack(spacing: 20) {
                ForEach(0..<userViewModel.maxDigits, id: \.self) { index in
                    Circle()
                        .stroke(Color(userViewModel.pinColor), lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .background(
                            Circle()
                                .fill(userViewModel.confirmNewPin.count > index ? Color(userViewModel.pinColor) : Color.clear)
                        )
                        .scaleEffect(userViewModel.confirmNewPin.count > index ? 1.1 : 1.0)
                        .animation(.spring(response: 0.2), value: userViewModel.confirmNewPin.count)
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
                    if !userViewModel.confirmNewPin.isEmpty {
                        userViewModel.confirmNewPin.removeLast()
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
                    userViewModel.confirmNewPin = ""
                    userViewModel.newPin = ""
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
            if userViewModel.confirmNewPin.count < userViewModel.maxDigits {
                userViewModel.confirmNewPin.append(value)
                
                if userViewModel.confirmNewPin.count == userViewModel.maxDigits {
                    if userViewModel.newPin == userViewModel.confirmNewPin {
                        userViewModel.createPin(newPin: userViewModel.newPin)
                        dismiss()
                    } else {
                        userViewModel.shakeAttempts += 1
                        userViewModel.confirmNewPin = ""
                    }
                }
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
