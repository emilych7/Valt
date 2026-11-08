import Foundation
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var usernameSelectionState: InputStatus = .idle
    @Published var emailSelectionState: InputStatus = .idle
    
    @Published var isSaving = false
    @Published var errorMessage: String?
    @AppStorage("selectedAppearance") var selectedAppearance: String = "Auto"
    
    private let userRepository: UserRepositoryProtocol
    private var availabilityTask: Task<Void, Never>?

    init(userRepository: UserRepositoryProtocol = UserRepository()) {
        self.userRepository = userRepository
    }

    var colorScheme: ColorScheme? {
        switch selectedAppearance {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil // 'nil' means use system settings
        }
    }

    func checkUsernameAvailability(for name: String, currentUsername: String) {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Cancel previous pending check
        availabilityTask?.cancel()
        
        // Immediate local checks
        if cleanName.isEmpty {
            usernameSelectionState = .invalid
            return
        }
        if cleanName == currentUsername.lowercased() {
            usernameSelectionState = .idle
            return
        }
        
        if cleanName.count < 3 {
            usernameSelectionState = .invalid
            return
        }

        usernameSelectionState = .loading

        availabilityTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s debounce
            guard !Task.isCancelled else { return }

            do {
                let isAvailable = try await userRepository.isUsernameAvailable(cleanName)
                if !Task.isCancelled {
                    usernameSelectionState = isAvailable ? .valid : .invalid
                }
            } catch {
                print("Availability check error: \(error)")
                usernameSelectionState = .error
            }
        }
    }
    
    // Saves preference to Firebase
    func updateAppearanceMode(for appearancePreference: String, currentPreference: String) {
        guard let uid = userRepository.currentUID else { return }
        let appearance = selectedAppearance
        Task {
            do {
                try await userRepository.updateAppearancePreference(uid: uid, appearance: appearance)
                print("Updated preference to \(appearance) in Firebase")
            } catch {
                print("Error updating appearance: \(error)")
            }
        }
    }
    
    func checkEmailAvailability(for email: String, currentEmail: String) {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        availabilityTask?.cancel()
        
        if cleanEmail.isEmpty {
            emailSelectionState = .idle
            return
        }
        
        if cleanEmail == currentEmail.lowercased() {
            emailSelectionState = .idle
            return
        }
        
        // Local Regex Validation
        guard isValidEmail(cleanEmail) else {
            emailSelectionState = .invalid
            errorMessage = "Please enter a valid email address."
            return
        }

        // Remote Firestore check
        emailSelectionState = .loading
        errorMessage = nil

        availabilityTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }

            do {
                let isAvailable = try await userRepository.isEmailAvailable(cleanEmail)
                if !Task.isCancelled {
                    if isAvailable {
                        emailSelectionState = .valid
                    } else {
                        emailSelectionState = .invalid
                        errorMessage = "This email is already in use."
                    }
                }
            } catch {
                emailSelectionState = .error
                errorMessage = "Database error. Please try again."
            }
        }
    }
    
    // Update Email (sends verification first)
    func updateEmail(to newEmail: String) async throws {
        try await userRepository.updateEmail(to: newEmail)
    }

    // Update Username
    func updateUsername(to newName: String, oldName: String) async throws {
        guard let uid = userRepository.currentUID else { return }
        try await userRepository.updateUsername(uid: uid, oldName: oldName, newName: newName)
        usernameSelectionState = .valid
        print("Successfully swapped username from \(oldName) to \(newName)")
    }
    
    func getPlaceholder(for type: EditFieldType, currentUsername: String) -> String {
        switch type {
        case .username:
            return currentUsername
        case .email:
            return userRepository.currentUserEmail ?? "Email"
        }
    }
    
    func deleteAccount(password: String? = nil) async throws {
        do {
            try await userRepository.deleteAccount(password: password)
        } catch {
            let nsError = error as NSError
            if nsError.code == 17014 { // AuthErrorCode.requiresRecentLogin.rawValue
                self.errorMessage = "For security, please sign out and sign back in to delete your account."
            } else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
