import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var isSaving: Bool = false
    @Published var errorMessage: String? = nil

    func validateUsername(_ name: String) -> Bool {
        return name.count >= 3 && !name.contains(" ")
    }
}
