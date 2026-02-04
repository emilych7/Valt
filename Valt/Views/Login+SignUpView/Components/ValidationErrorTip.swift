import SwiftUI
import TipKit

struct ValidationErrorTip: Tip {
    var id: String = UUID().uuidString
    
    @Parameter static var passwordHasError: Bool = false
    @Parameter static var emailHasError: Bool = false

    var title: Text
    var message: Text?
    
    var image: Image? {
        Image(systemName: "exclamationmark.circle.fill")
    }

    var rules: [Rule] {
        #Rule(Self.$passwordHasError) { $0 == true } // will show if the password error is triggered
    }
    
    var options: [TipOption] {
        [Tip.MaxDisplayCount(Int.max)]
    }
}
