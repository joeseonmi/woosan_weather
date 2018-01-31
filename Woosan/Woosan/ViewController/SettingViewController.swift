//
//  SettingViewController.swift
//  Woosan
//
//  Created by joe on 2017. 12. 10..
//  Copyright © 2017년 joe. All rights reserved.
//

import UIKit
import SwiftyJSON

class SettingViewController: UITableViewController {
    
    /*******************************************/
    //MARK:-          Property                 //
    /*******************************************/

    @IBOutlet weak var versionCheckLabel: UILabel!
    
    /*******************************************/
    //MARK:-          Life Cycle               //
    /*******************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if isUpdateAvailable() {
            self.versionCheckLabel.text = "업데이트하개!"
        } else {
            self.versionCheckLabel.text = "최신 버전이개!"
        }
    }
    
    
    /*******************************************/
    //MARK:-            Func                   //
    /*******************************************/
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 3 {
            if isUpdateAvailable() {
                if let appStoreURL = URL(string: "https://itunes.apple.com/app/id1338730084?mt=8"),
                    UIApplication.shared.canOpenURL(appStoreURL) {
                    if #available(iOS 10.2, *) {
                        UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(appStoreURL)
                    }
                }
            } else {
                
            }
        }
    }
    
    @IBAction func tappedCloseBtn(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func isUpdateAvailable() -> Bool{
        let version = Bundle.main.infoDictionary
        guard let bundleURL = URL(string: "http://itunes.apple.com/lookup?bundleId=kr.devjoe.Woosan&country=kr") else { return false }
        //번들 아이디로 결과가 계속0인데, 한국 앱스토어에만 올렸기때문에 파라미터를 더 넣어줘야했음
        let latestAppVersion = try? Data(contentsOf: bundleURL)
        guard let data = version, let latestData = latestAppVersion else { return false }
        let currentAppData = JSON(data)
        let appstoreAppData = JSON(latestData)
        let currentAppVer = currentAppData["CFBundleShortVersionString"].stringValue
        let currentASVer = appstoreAppData["results"][0]["version"].stringValue
        if !(currentASVer == currentAppVer) {
            return true
        }
        return false
    }
    
}

