import Foundation
import FirebaseFirestore
import FirebaseAuth

extension Notification.Name {
    static let userDidSignOut = Notification.Name("UserDidSignOut")
    static let userSessionInvalidated = Notification.Name("UserSessionInvalidated")
}

extension Error {
    var isUnauthenticatedError: Bool {
        let nsError = self as NSError
        if nsError.domain == FirestoreErrorDomain {
            if nsError.code == FirestoreErrorCode.unauthenticated.rawValue ||
               nsError.code == FirestoreErrorCode.permissionDenied.rawValue {
                return true
            }
        }
        if nsError.domain == AuthErrorDomain {
            if nsError.code == AuthErrorCode.userNotFound.rawValue ||
               nsError.code == AuthErrorCode.userTokenExpired.rawValue ||
               nsError.code == AuthErrorCode.invalidUserToken.rawValue ||
               nsError.code == AuthErrorCode.userDisabled.rawValue {
                return true
            }
        }
        return false
    }
}
