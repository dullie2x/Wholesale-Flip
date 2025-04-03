import SwiftUI
import GoogleMobileAds
import StoreKit

@main
struct Wholesale_FlipApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showSplash = true
    
    // Create app review manager as a StateObject
    @StateObject private var reviewManager = AppReviewManager()
    
    var body: some Scene {
        WindowGroup {
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
                    .environmentObject(reviewManager)
            }
        }
    }
}

// Dedicated review manager to track user engagement and handle review requests
class AppReviewManager: ObservableObject {
    // Track if we've already requested a review in this app version
    private var hasRequestedReviewInCurrentVersion: Bool {
        get {
            let lastVersionPrompted = UserDefaults.standard.string(forKey: "lastVersionPromptedForReview") ?? ""
            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            return lastVersionPrompted == currentVersion
        }
        set {
            if newValue {
                let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
                UserDefaults.standard.set(currentVersion, forKey: "lastVersionPromptedForReview")
            }
        }
    }
    
    // Track successful calculations count
    private var successfulCalculationsCount: Int {
        get { UserDefaults.standard.integer(forKey: "successfulCalculationsCount") }
        set { UserDefaults.standard.set(newValue, forKey: "successfulCalculationsCount") }
    }
    
    // Track if user has submitted a review
    private var hasEverSubmittedReview: Bool {
        get { UserDefaults.standard.bool(forKey: "hasSubmittedReview") }
        set { UserDefaults.standard.set(newValue, forKey: "hasSubmittedReview") }
    }
    
    // Called when a calculation is performed successfully
    func registerSuccessfulCalculation() {
        successfulCalculationsCount += 1
        
        // Check if we should request a review
        checkAndRequestReviewIfAppropriate()
    }
    
    // Logic to determine if and when to request a review
    private func checkAndRequestReviewIfAppropriate() {
        // Skip if user has already been prompted in this version
        guard !hasRequestedReviewInCurrentVersion else { return }
        
        // Core logic for when to show the review prompt
        // Option 1: After 2 successful calculations for new users
        if !hasEverSubmittedReview && successfulCalculationsCount >= 2 {
            requestReview()
            return
        }
        
        // Option 2: After 5 successful calculations for returning users
        if hasEverSubmittedReview && successfulCalculationsCount >= 5 {
            requestReview()
            return
        }
    }
    
    // Request the review and update tracking
    private func requestReview() {
        // Small delay to ensure the user has seen their calculation results first
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Request the review
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
                
                // Mark that we've requested a review in this version
                self.hasRequestedReviewInCurrentVersion = true
                
                // Assume the user submitted a review (since we can't actually track this)
                // This will ensure we don't ask too frequently
                self.hasEverSubmittedReview = true
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

        // Delay loading the ad (give the app time to load)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let isPremium = UserDefaults.standard.bool(forKey: "isPremiumUser")
            if !isPremium {
                self.loadAd()
            } else {
                print("👑 Premium user — skipping app open ad.")
            }
        }

        return true
    }

    func loadAd() {
        let request = Request()

        AppOpenAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Failed to load app open ad: \(error.localizedDescription)")
                return
            }

            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self

            // Wait a bit more before showing ad
            DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController,
                   let ad = self.appOpenAd {
                    ad.present(from: rootVC)
                }
            }
        }
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        appOpenAd = nil
    }
}

