//
//  ThemeTableViewCell.swift
//  Woosan
//
//  Created by joe on 2017. 12. 10..
//  Copyright © 2017년 joe. All rights reserved.
//

import UIKit

class ThemeTableViewCell: UITableViewCell {

    @IBOutlet weak var themeImage: UIImageView!
    @IBOutlet weak var themeTitle: UILabel!
    @IBOutlet weak var themeSubsc: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
       self.themeImage.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
