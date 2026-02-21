import SwiftUI

struct ProfileTabView: View {
    @Binding var selectedTab: ProfileTab
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            tabButton(image: "homeCardsIcon", tab: .all)
            tabButton(image: "favoriteIcon", tab: .favorited)
            tabButton(image: "publishIcon", tab: .published)
            tabButton(image: "hideIcon", tab: .hidden)
        }
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity)
        .background(Color("AppBackgroundColor"))
        .overlay(
            Rectangle()
                .fill(Color("TextColor").opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    @ViewBuilder
    private func tabButton(image: String, tab: ProfileTab) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 8) {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(selectedTab == tab ? Color("TextColor") : .gray)
                    .padding(.bottom, 2)
                    .opacity("hideIcon" == image ? 0.4 : 1 )
                
                ZStack {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 1)
                    
                    if selectedTab == tab {
                        Rectangle()
                            .fill(Color("TextColor"))
                            .frame(height: 1)
                            .padding(.horizontal, 20)
                            .matchedGeometryEffect(id: "underline", in: animation)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct LockedTabPlaceholder: View {
    var action: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: "lock.fill")
                .font(.system(size: 70))
                .foregroundColor(Color("TextColor").opacity(0.5))
            
            Button("Enter PIN") {
                action()
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(Color("TextColor"))
            .foregroundColor(Color("AppBackgroundColor"))
            .cornerRadius(12)
            .font(.custom("OpenSans-Regular", size: 15))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("TextFieldBackground").opacity(0.7))
    }
}

struct PinEntryView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isUnlocked: Bool
    
    @State private var enteredPin: String = ""
    @State private var shakeAttempts: CGFloat = 0
    private let correctPin = "1234"
    private let maxDigits = 4
    
    private let feedbackGenerator = UINotificationFeedbackGenerator()

    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 15) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 30))
                    .foregroundColor(Color("TextColor"))
                    .modifier(ShakeEffect(animatableData: shakeAttempts))
                
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
                ForEach(0..<maxDigits, id: \.self) { index in
                    Circle()
                        .stroke(Color("TextColor"), lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .background(
                            Circle()
                                .fill(enteredPin.count > index ? Color("TextColor") : Color.clear)
                        )
                        .scaleEffect(enteredPin.count > index ? 1.1 : 1.0)
                        .animation(.spring(response: 0.2), value: enteredPin.count)
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
                deleteButton
            }
            .padding(.horizontal, 40)
            
            HStack {
                Spacer()
                
                Button {
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
            if enteredPin.count < maxDigits {
                enteredPin.append(value)
                checkPin()
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

    private var deleteButton: some View {
        Button {
            if !enteredPin.isEmpty {
                enteredPin.removeLast()
            }
        } label: {
            Image(systemName: "delete.left")
                .font(.title2)
                .frame(width: 90, height: 90)
        }
        .buttonStyle(.plain)
    }

    private func checkPin() {
        guard enteredPin.count == maxDigits else { return }
        
        // Tiny delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if enteredPin == correctPin {
                withAnimation {
                    isUnlocked = true
                }
                dismiss()
            } else {
                withAnimation(.linear(duration: 0.4)) {
                    shakeAttempts += 1
                }
                
                feedbackGenerator.notificationOccurred(.error)
                
                // Clear the pin field after the shake
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    enteredPin = ""
                }
            }
        }
    }
}
