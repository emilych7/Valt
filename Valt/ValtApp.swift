import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        FirebaseApp.configure()
/*
        #if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        print("Firebase App Check Debug Provider Enabled")

        AppCheck.appCheck().token(forcingRefresh: true) { token, error in
            if let error = error {
                print("Failed to get App Check token: \(error.localizedDescription)")
            } else if let token = token {
                print("Debug App Check Token: \(token.token)")
            } else {
                print("No App Check token returned")
            }
        }
        
        #endif
 */

        return true
    }
}

@main
struct ValtApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}
