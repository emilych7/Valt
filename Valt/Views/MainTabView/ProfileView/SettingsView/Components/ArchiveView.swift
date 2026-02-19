import SwiftUI

struct ArchiveView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var selectedDraft: Draft?
    @Binding var showNote: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Archived Content")
                    .font(.custom("OpenSans-SemiBold", size: 24))
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    ZStack {
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color("ValtRed"))
                        Image("exitIcon")
                            .frame(width: 20, height: 20)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 10)
            .padding(.horizontal, 20)
            .padding(.bottom, 15)
            
            let filteredData = getFilteredData()
            
            VStack {
                if !filteredData.isEmpty {
                    ResponsiveGridView(items: filteredData) { draft in
                        CardView(userViewModel: userViewModel, draft: draft, selectedDraft: $selectedDraft, showNote: $showNote)
                    }
                } else if filteredData.isEmpty {
                    Text("No archived content.")
                        .font(.custom("OpenSans-Regular", size: 14))
                } else {
                    ProgressView()
                        .foregroundStyle(Color("TextColor"))
                }
            }
            
            Spacer()
        }
        .background(Color("AppBackgroundColor"))
        .foregroundColor(Color("TextColor"))
        .frame(maxWidth: .infinity)
    }
    
    private func getFilteredData() -> [Draft] {
        let allSorted = userViewModel.drafts.sorted { $0.timestamp > $1.timestamp }
        return allSorted.filter { $0.isArchived }
    }
}
