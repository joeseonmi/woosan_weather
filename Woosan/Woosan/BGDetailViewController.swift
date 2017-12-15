//
//  BGDetailViewController.swift
//  Woosan
//
//  Created by joe on 2017. 12. 11..
//  Copyright © 2017년 joe. All rights reserved.
//

import UIKit
import Kingfisher

class BGDetailViewController: UIViewController {
    
    /*******************************************/
    //MARK:-      Property                     //
    /*******************************************/
 
    var imageURL:String = ""
  
  
    @IBOutlet weak var bgImageView: UIImageView!
    
    @IBAction func tappedDownload(_ sender: UIButton) {
    print("누르면 포토라이브러리에 저장되게")
    }
    
    @IBAction func tappedClose(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    /*******************************************/
    //MARK:-      Life Cycle                   //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @objc func saveAlert() {
        let alert:UIAlertController = UIAlertController.init(title: "저장완료!", message: "배경화면이 저장됐어요.", preferredStyle: .alert)
        let alertBtn:UIAlertAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(alertBtn)
        self.present(alert, animated: true, completion: nil)
    }
    
}

