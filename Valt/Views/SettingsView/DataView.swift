import SwiftUI

struct DataView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Text("DataView")
        
        Button ("Leave", action: {dismiss()})
        
    }
    
    
}
