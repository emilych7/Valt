import SwiftUI
import FirebaseAuth

struct Message: Identifiable, Equatable {
    let id = UUID()
    let sender: Sender
    let content: String
    let timestamp: Date

    // Defines who sent the message
    enum Sender: String {
        case user = "You"
        case ai = "AI"
    }
}

struct PromptsView: View {
    @StateObject private var viewModel = PromptsViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Text("PromptGen")
                    .font(.custom("OpenSans-SemiBold", size: 24))
                Spacer()
            }
            .padding(.leading, 25)
            .padding(.top, 20)
            .padding(.trailing, 25)
            
            HStack (spacing: 15) {
                ZStack {
                    Text(viewModel.generatedPrompt)
                        .font(.custom("OpenSans-Regular", size: 15))
                        .foregroundColor(Color("TextColor"))
                        .padding(.horizontal, 10)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("TextFieldBackground"))
                        .stroke(Color("TextFieldBorder"), lineWidth: 1)
                }
                .frame(maxWidth: .infinity, maxHeight: 75)
            }
            .padding(.horizontal, 20)
            
            HStack {
                ZStack {
                    Rectangle()
                        .frame(height: 45)
                        .cornerRadius(12)
                        .foregroundColor(Color("RequestButtonColor"))
                    Button(action: {
                        // PromptWritingView()
                    }
                    ) {
                        HStack (spacing: 10) {
                            Text("Start Writing")
                                .font(.custom("OpenSans-SemiBold", size: 15))
                                .foregroundColor(.white)
                            Image("Write")
                                .frame(width: 15, height: 15)
                        }
                    }
                    
                }
                
                Spacer(minLength: 15)
                
                ZStack {
                    Rectangle()
                        .frame(height: 45)
                        .cornerRadius(12)
                        .foregroundColor(Color("RequestButtonNeutral"))
                    Button(action: {
                        viewModel.generatePromptFromDrafts()
                    }
                    ) {
                        HStack (spacing: 10) {
                            Text("New Prompt")
                                .font(.custom("OpenSans-SemiBold", size: 15))
                                .foregroundColor(.white)
                            Image("Refresh")
                                .frame(width: 15, height: 15)
                        }
                    }
                    
                }
            }
            .padding(.horizontal, 20)
            Spacer()
        }
        .background(Color("AppBackgroundColor"))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    PromptsView()
}
