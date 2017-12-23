//
//  forecastCollectionViewCell.swift
//  Woosan
//
//  Created by joe on 2017. 12. 23..
//  Copyright © 2017년 joe. All rights reserved.
//

import UIKit

class forecastCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var forecastHour: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var forecastTemp: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

}
