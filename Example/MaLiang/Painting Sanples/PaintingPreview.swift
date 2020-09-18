//
//  PaintingPreview.swift
//  MaLiang_Example
//
//  Created by Harley.xk on 2018/5/6.
//  Copyright © 2018年 Harley-xk. All rights reserved.
//

import UIKit
import Photos

class PaintingPreview: UIViewController {

    var image: UIImage?
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func savingAction(_ sender: Any) {
        checkAblumAuthorized { (error) in
            guard error == nil else {
                self.alert(message: error?.localizedDescription)
                return
            }
            self.performSavingAction()
        }
    }

    private func performSavingAction() {
        guard let image = image else {
            return alert(message: "Image does not exists")
        }
        
        PHPhotoLibrary.shared().performChanges({
            let data = image.pngData()!
            let png = UIImage(data: data)!
            PHAssetChangeRequest.creationRequestForAsset(from: png)
        }) { (succeed, error) in
            if let error = error {
                self.alert(message: error.localizedDescription)
            } else {
                self.alert(message: "Image saved to album succeeded!")
            }
        }
    }
    
    private func alert(message: String?) {
        let alert = UIAlertController(title: "Tips", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Album auth
    
    typealias FinishHandler = (Error?) -> ()

    func checkAblumAuthorized(finished: @escaping FinishHandler) {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch authorizationStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (_) in
                self.checkAblumAuthorized(finished: finished)
            }
        case .denied: alert(message: "can not access album")
        case .authorized: fallthrough
        case .limited: finished(nil)
        case .restricted:
            let error = NSError(domain: "Ablunm Authorization", code: -99, userInfo: [NSLocalizedDescriptionKey: "can not access album"])
            finished(error)
        @unknown default: break
        }
    }
}
