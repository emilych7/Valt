import Foundation

struct AuthValidator {
    // Validate a password string
    static func isValidPassword(_ password: String) -> Bool {
        let trimmedPassword = password.trimmingCharacters(in: .whitespaces)
        let passwordRegx = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&<>*~:`-]).{8,}$"
        let passwordCheck = NSPredicate(format: "SELF MATCHES %@", passwordRegx)
        return passwordCheck.evaluate(with: trimmedPassword)
    }

    // Return requirements for UI feedback
    static func getMissingValidation(_ password: String) -> [String] {
        let trimmedPassword = password.trimmingCharacters(in: .whitespaces)
        var errors: [String] = []
        
        if !NSPredicate(format: "SELF MATCHES %@", ".*[A-Z]+.*").evaluate(with: trimmedPassword) {
            errors.append("least one uppercase")
        }
        if !NSPredicate(format: "SELF MATCHES %@", ".*[0-9]+.*").evaluate(with: trimmedPassword) {
            errors.append("at least one digit")
        }
        if !NSPredicate(format: "SELF MATCHES %@", ".*[!&^%$#@()/]+.*").evaluate(with: trimmedPassword) {
            errors.append("at least one symbol")
        }
        if !NSPredicate(format: "SELF MATCHES %@", ".*[a-z]+.*").evaluate(with: trimmedPassword) {
            errors.append("at least one lowercase")
        }
        if trimmedPassword.count < 8 {
            errors.append("at least 8 characters")
        }
        return errors
    }
}
