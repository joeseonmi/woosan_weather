//
//  LaunchViewController.swift
//  Woosan
//
//  Created by joe on 2018. 1. 23..
//  Copyright © 2018년 joe. All rights reserved.
//

import UIKit
import CoreLocation

class LaunchViewController: UIViewController {
    
   
    override func viewDidLoad() {
        super.viewDidLoad(
        
        let nextVC:notiPopup = storyboard?.instantiateViewController(withIdentifier: "onlyCanUseInKorea") as! notiPopup
        present(nextVC, animated: true, completion: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func goToNextViewController(){
        let nextViewController:ViewController = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.present(nextViewController, animated: true, completion: nil)
    }
}
