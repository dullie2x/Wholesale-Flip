//
//  Wholesale.swift
//  Wholesale Flip
//
//  Created by Gbolade Ariyo on 3/31/25.
//


//  Wholesale_FlipApp.swift
import SwiftUI
import GoogleMobileAds

@main
struct Wholesale_FlipApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashPage()
                    .onAppear {
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

class AppDelegate: NSObject, UIApplicationDelegate, FullScreenContentDelegate {
    var appOpenAd: AppOpenAd?
    let adUnitID = "ca-app-pub-3883739672732267/3331636077"

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        MobileAds.shared.start(completionHandler: nil)

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

        AppOpenAd.load(withAdUnitID: adUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Failed to load app open ad: \(error)")
                return
            }

            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController,
               let ad = self.appOpenAd {
                ad.present(fromRootViewController: rootVC)
            } else {
                print("⚠️ Unable to present app open ad — no rootViewController found.")
            }
        }
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        appOpenAd = nil
    }
}