import SwiftUI

struct PreferencesView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Text("PreferencesView")
        
        Button ("Leave", action: {dismiss()})
        
    }
    
    
}
