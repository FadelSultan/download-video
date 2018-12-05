//
//  clsDownload.swift
//  Hero
//
//  Created by fadel sultan on 8/19/18.
//  Copyright © 2018 fadel sultan. All rights reserved.
//

import Foundation
import Alamofire
import Photos
import UIKit
import AssetsLibrary
import PopupDialog
import Firebase

protocol downloadDelegate {
    func downloadIsSuccess(_ state:Bool)
    func downloadComplate(_ num:Double)
    func counterDownload(_ totalBytesWritten : Float , totalUnitCount : Float)
    func cancelDownload()
    func errorDownload()
    func msgAuthWrong()
}

class clsDownlosd {
    
    static var share = clsDownlosd()
    
    
    var delegate:downloadDelegate?
    
    var downloadIsStart = false
    var request: Alamofire.Request?
    
    
    func checkUrl(_ urlString:String) {
        
        if urlString.lowercased().contains("twitter") || urlString.lowercased().contains("facebook") || urlString.lowercased().contains("instgram") || urlString.lowercased().contains("youtube") || urlString.lowercased().contains("yout"){
            if UserDefaults.standard.bool(forKey: "authDownload"){
                getUrlForDownload(urlString)
            }else {
                self.delegate?.msgAuthWrong()
            }
            
        }else {
            downloadDirctUrl(urlString)
        }
    }
    
    func getUrlForDownload(_ urlString:String) {
        
//        Set your api for download 
        let url = "https://www.saveoffline.com/process/?url="
        
        print("\(url)\(urlString)")
        
        Alamofire.request(URL(string: "\(url)\(urlString)")!).responseJSON { (data) in
            if let e = data.error {
                print("Error " , e.localizedDescription)
                self.getUrlForDownload2(urlString)
                return
            }
                if data.result.isSuccess {
                    print("id video " , (((data.result.value as AnyObject).object(forKey: "urls") as! NSArray)[0] as AnyObject).object(forKey: "id") ?? "Nothing")
                    
                    let urlVideo = (((data.result.value as AnyObject).object(forKey: "urls") as! NSArray)[0] as AnyObject).object(forKey: "id") ?? "Nothing"
                    self.downloadDirctUrl(urlVideo as! String)
                }else {
                    self.delegate?.errorDownload()
                }
                
                
        }

    }
    
    func getUrlForDownload2(_ urlString:String) {
        
        let url = "https://www.saveoffline.com/process/?url="
        
        print("\(url)\(urlString)")
        
        Alamofire.request(URL(string: "\(url)\(urlString)")!).responseJSON { (data) in
            if let e = data.error {
                print("Error " , e.localizedDescription)
                self.delegate?.errorDownload()
                return
            }
            if data.result.isSuccess {
                print("id video " , (((data.result.value as AnyObject).object(forKey: "urls") as! NSArray)[0] as AnyObject).object(forKey: "id") ?? "Nothing")
                
                let urlVideo = (((data.result.value as AnyObject).object(forKey: "urls") as! NSArray)[0] as AnyObject).object(forKey: "id") ?? "Nothing"
                self.downloadDirctUrl(urlVideo as! String)
            }else {
                self.delegate?.errorDownload()
            }
            
            
        }
        
    }
    
    
    
    func downloadDirctUrl(_ urlString:String) {
        
        let destination = DownloadRequest.suggestedDownloadDestination()
        
       request = Alamofire.download(urlString, to: destination)
            .downloadProgress(closure: { (progress) in
                DispatchQueue.main.async {
                    self.delegate?.downloadComplate(progress.fractionCompleted)
                    self.delegate?.counterDownload(Float(progress.completedUnitCount), totalUnitCount: Float(progress.totalUnitCount))
                }
                
            })
            .response { response in // method defaults to `.get`
                
                if let urlVideo = response.destinationURL {
                    print("url Mp4" , urlVideo)
                    self.saveVideoToLibrary(urlVideo)
                }
        }
        
    }
    
    func saveVideoToLibrary(_ urlVideo:URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: urlVideo)
        }) { saved, error in
            if saved {
                self.delegate?.downloadIsSuccess(true)
            }else {
                self.delegate?.downloadIsSuccess(false)
            }
        }

    }
    
    func cancelDownload() {
        request?.cancel()
        self.delegate?.cancelDownload()
    }
    
    
    func authDownload(result : @escaping (_ value:Bool)->()) {
        var db: Firestore!
        
        db = Firestore.firestore()
        
        let docRef = db.collection("authDownload").document("70uDAkjkNsKqpk1K5vG8")
        
        docRef.getDocument { (document, error) in
            
            if let dict = document?.data() {
                result((dict["IsAuthDownload"] as? Bool)!)
            }
            if error != nil {
                result(false)
                print("error " , error!.localizedDescription)
            }
            
        }
    }
    
}
