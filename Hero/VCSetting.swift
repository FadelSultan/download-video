//
//  VCSetting.swift
//  Hero
//
//  Created by fadel sultan on 8/23/18.
//  Copyright © 2018 fadel sultan. All rights reserved.
//

import UIKit
import GoogleMobileAds

class VCSetting: UIViewController {

    
    
    @IBOutlet weak var viewBanner: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clsGoogleAds.share.setupBannerAds(bannerView: viewBanner, viewController: self, adUnitID: "ca-app-pub-4617753056518804/7741578596")
    }

    @IBAction func btnTwitter(_ sender: Any) {
        let url = URL(string: "https://twitter.com/fadel_sultan")
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url!)
        }
    }
    
    @IBAction func btnCloseVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
   
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
