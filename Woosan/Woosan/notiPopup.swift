//
//  notiPopup.swift
//  Woosan
//
//  Created by joe on 2018. 1. 3..
//  Copyright © 2018년 joe. All rights reserved.
//

import UIKit
import Lottie

class notiPopup: UIViewController {
    /*******************************************/
    //MARK:-            Outlet                 //
    /*******************************************/
    
    @IBOutlet weak var bgView: UIView!
    
    /*******************************************/
    //MARK:-         LifeCycle                 //
    /*******************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playNotiLottie()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*******************************************/
    //MARK:-            Func                   //
    /*******************************************/
    
    func playNotiLottie() {
        self.bgView.layer.sublayers = nil
        let animationView = LOTAnimationView(name: "doggy")
        self.bgView.addSubview(animationView)
        animationView.frame.size = CGSize(width: self.bgView.frame.width, height: self.bgView.frame.height)
        animationView.loopAnimation = true
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        
    }

}
