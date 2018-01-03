//
//  ThemeViewController.swift
//  Woosan
//
//  Created by joe on 2017. 12. 10..
//  Copyright © 2017년 joe. All rights reserved.
//

import UIKit

class ThemeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    // TODO: - :: 지금은 model과 controller가 다 붙어있는...고쳐야댕
    
    let titles:[String] = ["우산 챙기개!(기본)",
                           "우산 챙겼냥!"]
    
    let subscrip:[String] = ["우산챙기개! 기본테마. 강아지가 뛰어댕겨요.",
                             "얼룩이 고양이가 뛰어댕겨요."]
    
    let image:[String] = ["doggythemIcon",
                          "dungsilcatthemIcon"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "테마"
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "ThemeTableViewCell", bundle: nil), forCellReuseIdentifier: "ThemeTableViewCell")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension ThemeViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeTableViewCell", for: indexPath) as! ThemeTableViewCell
        cell.themeTitle.text = self.titles[indexPath.row]
        cell.themeSubsc.text = self.subscrip[indexPath.row]
        cell.themeImage.image = UIImage(named: self.image[indexPath.row])
        return cell
    }
}

extension ThemeViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
