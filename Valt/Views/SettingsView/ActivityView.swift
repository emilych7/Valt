import SwiftUI

struct ActivityView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Text("ActivityView")
        
        Button ("Leave", action: {dismiss()})
        
    }
    
    
}
