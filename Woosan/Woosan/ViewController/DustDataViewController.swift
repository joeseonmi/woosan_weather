//
//  DustDataViewController.swift
//  Woosan
//
//  Created by joe on 2018. 2. 24..
//  Copyright © 2018년 joe. All rights reserved.
//

import UIKit
import SwiftyJSON

class DustDataViewController: UIViewController {
    
    @IBOutlet weak var map: UIImageView!
  
    @IBOutlet weak var incheon: UIView!
    @IBOutlet weak var seoul: UIView!
    @IBOutlet weak var gyeonggi: UIView!
    @IBOutlet weak var gangwon: UIView!
    @IBOutlet weak var chungnam: UIView!
    @IBOutlet weak var daejeon: UIView!
    @IBOutlet weak var chungbuk: UIView!
    @IBOutlet weak var gyeongbuk: UIView!
    @IBOutlet weak var jeonbuk: UIView!
    @IBOutlet weak var gyeongnam: UIView!
    @IBOutlet weak var daegu: UIView!
    @IBOutlet weak var ulsan: UIView!
    @IBOutlet weak var busan: UIView!
    @IBOutlet weak var jeonnam: UIView!
    @IBOutlet weak var jeju: UIView!
    
//    var dustData:[String:todayDust] = [:] {
//        didSet {
//            self.buildDustView()
//        }
//    }

    @IBAction func closeBtn(_ sender: UIButton) {
        self.closeVC()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dustAPIController.shared.todayDustInfo("seoul") { (dict) in
            print(dict)
//            self.dustData = dict
        }
            
    }
    
//    private func buildDustView() {
//
//        let keys = dustData.keys.sorted()
//        for key in keys {
//            guard let tempData = dustData[key] else { return }
//            let bgView = self.convertView(name: key)
//            let tempView = self.resisterDustView(location: tempData.location,
//                                                 dustValue: tempData.dustValue,
//                                                 comment: tempData.dustComment)
//            bgView.addSubview(tempView)
//            tempView.frame.size.width = self.jeju.frame.size.width
//            tempView.frame.size.height = self.jeju.frame.size.height
//            tempView.contentMode = .scaleAspectFit
//        }
//    }
    
    private func convertView(name:String) -> UIView {
        switch name {
        case "seoul": return self.seoul
        case "incheon": return self.incheon
        case "gyeonggi": return self.gyeonggi
        case "gangwon": return self.gangwon
        case "chungnam": return self.chungnam
        case "daejeon": return self.daejeon
        case "chungbuk": return self.chungbuk
        case "gyeongbuk": return self.gyeongbuk
        case "jeonbuk": return self.jeonbuk
        case "gyeongnam": return self.gyeongnam
        case "daegu": return self.daegu
        case "ulsan": return self.ulsan
        case "busan": return self.busan
        case "jeonnam": return self.jeonnam
        case "jeju": return self.jeju
        default:
            return self.seoul
        }
    }
    
    private func resisterDustView(location:String, dustValue:String,comment:String) -> UIView {
        var isiPhonSE:Bool = false
        let widthSize = self.map.frame.width
        if widthSize <= 304.0 {
            isiPhonSE = true
        }
        let dustView = UINib(nibName: "DustView", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as! DustView
        var background:String = ""
        var icon:String = ""
        if comment == "좋음" {
            background = "dust_sky"
            icon = "widgetCattyhead"
        } else if comment == "보통" {
            background = "dust_yellow"
            icon = "widgetCattyhead"
        } else if comment == "나쁨" {
            background = "dust_ong"
            icon = "widgetCattyhead"
        } else if comment == "매우 나쁨" {
            background = "dust_red"
            icon = "widgetCattyhead"
        } else {
            background = "dust_sky"
            icon = "widgetCattyhead"
        }
        dustView.background.image = UIImage(named: background)
        dustView.dustIcon.image = UIImage(named: icon)
        dustView.location.text = location
        dustView.dustScrip.text = comment
        if isiPhonSE {
            dustView.dustScore.isHidden = true
        }
        dustView.dustScore.text = dustValue
        return dustView
    }
    
    
    private func closeVC(){
        self.dismiss(animated: true, completion: nil)
    }
}
