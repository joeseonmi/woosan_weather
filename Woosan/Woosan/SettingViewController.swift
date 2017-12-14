//
//  SettingViewController.swift
//  Woosan
//
//  Created by joe on 2017. 12. 10..
//  Copyright © 2017년 joe. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {
    
    /*******************************************/
    //MARK:-          Property                 //
    /*******************************************/
    
    
    /*******************************************/
    //MARK:-          Life Cycle               //
    /*******************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    /*******************************************/
    //MARK:-            Func                   //
    /*******************************************/
    
    @IBAction func tappedCloseBtn(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

