import SwiftUI
import GoogleMobileAds

@main
struct Wholesale_FlipApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showSplash = true // Add a boolean state variable

    var body: some Scene {
        WindowGroup {
            // Use a conditional to show either the splash screen or the main app content
            if showSplash {
                SplashPage()
                    .onAppear {
                        // Automatically dismiss the splash screen after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                MainTabView()
            }
        }
    }
}

// Class for App Delegate with ad implementation
class AppDelegate: NSObject, UIApplicationDelegate, FullScreenContentDelegate {
    var appOpenAd: AppOpenAd?
    let adUnitID = "ca-app-pub-3883739672732267/3331636077"

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        MobileAds.shared.start(completionHandler: nil)

        // Only load ads if user is NOT premium
        let isPremium = UserDefaults.standard.bool(forKey: "isPremiumUser")
        if !isPremium {
            loadAd()
        } else {
            print("👑 Premium user — skipping app open ad.")
        }

        return true
    }

    func loadAd() {
        let request = Request()

        AppOpenAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Failed to load app open ad: \(error)")
                return
            }

            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController,
               let ad = self.appOpenAd {
                ad.present(from: rootVC)
            }
        }
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        appOpenAd = nil
    }
}

