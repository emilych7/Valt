import SwiftUI

struct SecurityView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Text("SecurityView")
        
        Button ("Leave", action: {dismiss()})
        
    }
    
    
}
