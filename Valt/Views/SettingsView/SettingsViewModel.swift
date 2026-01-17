import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var isSaving: Bool = false
    @Published var errorMessage: String? = nil
    
    @AppStorage("selectedAppearance") var selectedAppearance: String = "Auto"

    // Convert the string selection into a SwiftUI ColorScheme
    var colorScheme: ColorScheme? {
            switch selectedAppearance {
            case "Light": return .light
            case "Dark": return .dark
            default: return nil // 'nil' means use system settings
            }
        }

    func validateUsername(_ name: String) -> Bool {
        return name.count >= 3 && !name.contains(" ")
    }
}
