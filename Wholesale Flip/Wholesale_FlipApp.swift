//
//  Wholesale_FlipApp.swift
//  Wholesale Flip
//
//  Created by Abdulmalik Ariyo on 5/30/23.
//

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
                InitialView()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, GADFullScreenContentDelegate {
    var appOpenAd: GADAppOpenAd?
    
    //let adUnitID = "ca-app-pub-3940256099942544/5575463023"
    let adUnitID = "ca-app-pub-3883739672732267/3331636077"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        //GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "4da0971c9044fbe31d76acce10046d83" ]
        loadAd()
        return true
    }

    func loadAd() {
        let request = GADRequest()
        GADAppOpenAd.load(withAdUnitID: adUnitID, request: request, orientation: UIInterfaceOrientation.portrait, completionHandler: { [self] (ad, error) in
            if error != nil {
                return
            }
            appOpenAd = ad
            appOpenAd?.fullScreenContentDelegate = self
            if let ad = appOpenAd {
                ad.present(fromRootViewController: UIApplication.shared.windows.first!.rootViewController!)
            }
        })
    }

    // GADFullScreenContentDelegate methods
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        appOpenAd = nil
    }
}

