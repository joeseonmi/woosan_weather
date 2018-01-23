//
//  EtcViewController.swift
//  Woosan
//
//  Created by joe on 2017. 12. 10..
//  Copyright © 2017년 joe. All rights reserved.
//

import UIKit

class EtcViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let info:[String] = ["Alamofire","SwiftyJSON","KingFisher","FireBase","Lottie"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "출처"
        self.tableView.dataSource = self

    }

}

extension EtcViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.info.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = info[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
}

