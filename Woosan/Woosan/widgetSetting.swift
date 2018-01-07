//
//  widgetSetting.swift
//  Woosan
//
//  Created by joe on 2018. 1. 4..
//  Copyright © 2018년 joe. All rights reserved.
//

import UIKit

class widgetSetting: UIViewController {

    @IBOutlet weak var pageControll: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "위젯 설정하기"
        self.scrollView.delegate = self
        self.scrollView.isPagingEnabled = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension widgetSetting : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = self.scrollView.contentOffset.x / self.scrollView.frame.size.width
        self.pageControll.currentPage = Int(page)
    }
}
