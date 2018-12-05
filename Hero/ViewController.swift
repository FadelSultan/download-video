//
//  ViewController.swift
//  Hero
//
//  Created by fadel sultan on 8/19/18.
//  Copyright © 2018 fadel sultan. All rights reserved.
//

import UIKit
import PopupDialog
import UICircularProgressRing
import Foundation
import GoogleMobileAds
import SwiftyRate

class ViewController: UIViewController , downloadDelegate , adMobDelegate {
    

    @IBOutlet weak var viewAdsNative: UIView!
    
    @IBOutlet weak var viewBanner: GADBannerView!
    
    @IBOutlet weak var labelCounter: UILabel!
    
    @IBOutlet weak var textFieldUrl: UITextField!
    @IBOutlet weak var btnStartDownload: UIButton!
    
    @IBOutlet weak var imageViewSetting: UIImageView!
    
    @IBOutlet weak var progressView: UICircularProgressRing!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupRateApp()
        
        clsGoogleAds.share.loadGoogleAds()
        
        clsGoogleAds.share.viewAdsNative = viewAdsNative
        clsGoogleAds.share.setupAdsNativView(viewController: self, adUnitID: "ca-app-pub-4617753056518804/3716797006")
        
        clsGoogleAds.share.delegate = self
        clsDownlosd.share.delegate = self
        
        self.btnStartDownload.layer.masksToBounds = true
        self.btnStartDownload.layer.cornerRadius = 60
        
    }
    
    func setupRateApp() {
        let launchCount = UserDefaults.standard.integer(forKey: "setupRateApp")
        if launchCount <= 1 {
            SwiftyRate.request(from: self, afterAppLaunches: 5)
            UserDefaults.standard.set((launchCount + 1), forKey: "setupRateApp")
            print("launchCount " , launchCount)
        }
        
    }
    
    func runAdsBaneer() {
        clsGoogleAds.share.setupBannerAds(bannerView: viewBanner, viewController: self, adUnitID: "ca-app-pub-4617753056518804/7741578596")
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func btnStartDownload(_ sender: Any) {
        
        self.view.endEditing(true)
        if (self.textFieldUrl.text?.isEmpty)! {
            self.messageWrong("لم يتم إدخال الرابط \n يجب كتابة الرابط اولاً ")
            return
        }
        
        if !self.validatUrl(urlString: self.textFieldUrl.text) {
            self.messageWrong("الرابط المدخل غير صحيح !")
            self.resetDownload()
            return
        }
        
        if self.btnStartDownload.titleLabel?.text == "تحميل" && !clsDownlosd.share.downloadIsStart
        {
            self.btnStartDownload.setTitle("إلغاء التحميل", for: .normal)
            clsDownlosd.share.downloadIsStart = true
            clsDownlosd.share.checkUrl((self.textFieldUrl.text?.trimmingCharacters(in: .whitespacesAndNewlines))!)
        }else {
            clsDownlosd.share.cancelDownload()
        }
        
    }
    @IBAction func btnVCSetting(_ sender: Any) {
        let navi = self.storyboard?.instantiateViewController(withIdentifier: "Setting") as! UINavigationController
        self.present(navi, animated: true, completion: nil)
    }
    
    func downloadComplate(_ num: Double) {
        print("num " , num)
        self.progressView.maxValue = 1
        self.progressView.value = CGFloat(num)
    }
    
    
    func counterDownload(_ totalBytesWritten: Float, totalUnitCount: Float) {
        print("totalBytesWritten " , totalBytesWritten)
        print("totalUnitCount " , totalUnitCount)
        
         self.labelCounter.text =  "\(Double(totalBytesWritten / 1024 / 1024).rounded(toPlaces: 1))MB / \(Double(totalUnitCount / 1024 / 1024).rounded(toPlaces: 1))MB"
    }
    
    func cancelDownload() {
        self.resetDownload()
    }
    
    func downloadIsSuccess(_ state: Bool) {
        print("state " , state)
        if state {
            
            self.msgDownloadDone("تم حفظ الفيديو بالاستديو بنجاح ")
            
            DispatchQueue.main.async {
                self.resetDownload()
            }
        }
    }
    
    func errorDownload() {
        self.resetDownload()
        self.messageWrong("لا يمكن جلب الفيديو من الموقع نأمل المحاولة في وقتٍ لاحق ")
    }
    
    func msgAuthWrong() {
        self.resetDownload()
        self.messageWrong("إن سياسة الموقع المراد تحميل الفيديو منه لا تسمح بذالك نأمل إختيار المواقع التي تسمح بالتحميل وشكراً ")
    }
}

extension ViewController {
    
    
    func msgDownloadDone(_ msg : String) {
        
        DispatchQueue.main.async {
            let popup = PopupDialog(title: "✅", message: msg)
            
            let cancel = CancelButton(title: "موافق") {
                clsGoogleAds.share.showGoogleAds(viewController: self)
            }
            
            popup.addButton(cancel)
            
            self.present(popup, animated: true, completion: nil)
        }
        
    }
    
    func messageRight(_ msg : String) {
        
        DispatchQueue.main.async {
            let popup = PopupDialog(title: "✅", message: msg)
            
            let cancel = CancelButton(title: "موافق") {}
            
            popup.addButton(cancel)
            
            self.present(popup, animated: true, completion: nil)
        }
        
    }
    
    func messageWrong(_ msg : String) {
        
        DispatchQueue.main.async {
            let popup = PopupDialog(title: "❌", message: msg)
            
            let cancel = CancelButton(title: "موافق") {}
            
            popup.addButton(cancel)
            
            self.present(popup, animated: true, completion: nil)
        }
        
    }
    
    func resetDownload() {
        self.btnStartDownload.setTitle("تحميل", for: .normal)
        clsDownlosd.share.downloadIsStart = false
        self.textFieldUrl.text?.removeAll()
        self.progressView.value = 0
        self.labelCounter.text?.removeAll()
        
    }
    
//    Validat url
    func validatUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = URL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

