//
//  AdsAdmob.swift
//  snapApp
//
//  Created by fadel sultan on 5/7/18.
//  Copyright © 2018 fadel sultan. All rights reserved.
//



import Foundation

import GoogleMobileAds


protocol adMobDelegate {
    func runAdsBaneer()
}
class clsGoogleAds: NSObject , GADInterstitialDelegate{
    
    
    var delegate:adMobDelegate?
    
    static var share = clsGoogleAds()
    
    //admob Ads  native
    var adLoader: GADAdLoader!
    
    var viewAdsNative:UIView!
    
    
    var nativeAdView: GADUnifiedNativeAdView!
    
    
    var interstitial: GADInterstitial!
    
    func loadGoogleAds() {
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-4617753056518804/9657032160")
        let request = GADRequest()
        request.testDevices = ["07f1fce20a9874f9018fffd952200bbb" , kGADSimulatorID]
        
        interstitial.delegate = self
        interstitial.load(request)
    }
    
    
    func showGoogleAds(viewController:UIViewController) {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: viewController)
            loadGoogleAds()
        } else {
            print("Ad wasn't ready")
            loadGoogleAds()
        }
    }
    
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
}


extension clsGoogleAds : GADBannerViewDelegate{
    
    // add banner ads
    func setupBannerAds(bannerView:GADBannerView , viewController:UIViewController , adUnitID:String) {
        bannerView.delegate = self
        
        bannerView.adUnitID = adUnitID
        let request = GADRequest()
//        request.testDevices = ["07f1fce20a9874f9018fffd952200bbb" , kGADSimulatorID]
        bannerView.rootViewController = viewController
        bannerView.load(request)
        
    }
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd banner")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    
}


extension clsGoogleAds : GADAdLoaderDelegate , GADUnifiedNativeAdLoaderDelegate , GADUnifiedNativeAdDelegate  {
    
    func setupAdsNativView(viewController:UIViewController , adUnitID:String) {
        self.viewAdsNative.isHidden = true
        
        adLoader = GADAdLoader(adUnitID: adUnitID, rootViewController: viewController,
                               adTypes: [ .unifiedNative ], options: nil)
        adLoader.delegate = self
        let request = GADRequest()
        request.testDevices = ["07f1fce20a9874f9018fffd952200bbb" , kGADSimulatorID]
        adLoader.load(request)
        

        
        
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        print("adLoaderDidFinishLoading")
        self.viewAdsNative.isHidden = false
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        delegate?.runAdsBaneer()
        print("Error is " , error.localizedDescription)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        
        self.nativeAdView = Bundle.main.loadNibNamed("AdsNativeApp", owner: nil, options: nil)?.first as? GADUnifiedNativeAdView
        self.viewAdsNative.addSubview(self.nativeAdView)
        
        // TODO: Make sure to add the GADNativeAppInstallAdView to the view hierarchy.
        print("Load ads native")
        // Associate the app install ad view with the app install ad object. This is
        // required to make the ad clickable as well as populate the media view.
        self.nativeAdView.nativeAd = nativeAd
        nativeAd.delegate = self
        
        (self.nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        (self.nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        (self.nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        
    }


    
}

