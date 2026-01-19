import Foundation

enum ContentLoadingState: Equatable {
    case loading
    case empty
    case error(String) 
    case complete
}
