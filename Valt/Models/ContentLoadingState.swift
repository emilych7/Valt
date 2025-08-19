import Foundation

enum ContentLoadingState {
    case loading
    case empty
    case error(Error)
    case complete
}
