//
//  BGDetailViewController.swift
//  Woosan
//
//  Created by joe on 2017. 12. 11..
//  Copyright © 2017년 joe. All rights reserved.
//

import UIKit
import Kingfisher
import Photos

class BGDetailViewController: UIViewController {
    
    /*******************************************/
    //MARK:-      Property                     //
    /*******************************************/
 
    var imageURL:String = ""
  
  
    @IBOutlet weak var bgImageView: UIImageView!
    
    @IBAction func tappedDownload(_ sender: UIButton) {
        self.checkPermission()
        if let image = bgImageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @IBAction func tappedClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*******************************************/
    //MARK:-      Life Cycle                   //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bgImageView.kf.indicatorType = .activity
        if let url = URL(string: self.imageURL) {
            self.bgImageView.kf.setImage(with: url)
        }
        
       /*
        let url = imageURL
        if let thumbnailURL = URL(string: url) {
            //URL만들어주고
            let session = URLSession(configuration: .default)
            //URL을 다운로드하고 지지고볶고하려면 URL세션을 만들어야댐
            let download = session.dataTask(with: thumbnailURL) { (data, response, error) in
                if let dataError = error {
                    print("이미지 불러오기 에러: ",dataError)
                }
                if let dataResponse = response {
                    print("이미지 불러오기 응답: ",dataResponse)
                    guard let realData = data else { return }
                    DispatchQueue.main.sync {
                        self.bgImageView.image = UIImage(data: realData)
                        //통신을 계속하는거 같은데 해결책 찾아보기
                    }
                }else{
                    print("이미지가 엄성")
                }
            }
            download.resume()
        }
         */
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            let alert = UIAlertController.init(title: "저장 실패", message: "저장에 실패했어요.", preferredStyle: .alert)
            let action = UIAlertAction.init(title: "확인", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController.init(title: "저장!😘", message: "사진첩에 저장되었어요.", preferredStyle: .alert)
            let action = UIAlertAction.init(title: "확인", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func checkPermission() {
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized: break
        case .denied, .restricted: self.permissionAlert()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                switch status {
                case .authorized: break
                case .denied, .restricted: self.permissionAlert()
                case .notDetermined: break
                    
                }
            })
        }
    }
    
    func permissionAlert() {
        let alert = UIAlertController.init(title: "사진첩 접근 권한이 없습니다.", message: "설정에서 사진접근 권한을 허가해주세요.", preferredStyle: .alert)
        let action = UIAlertAction.init(title: "확인", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

