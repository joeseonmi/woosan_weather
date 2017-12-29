//
//  BGCollectionViewCell.swift
//  Woosan
//
//  Created by joe on 2017. 12. 10..
//  Copyright © 2017년 joe. All rights reserved.
//

import UIKit
import Photos

class BGCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bgthum: UIImageView!
    @IBAction func tappedDownload(_ sender: UIButton) {
        print("셀이있는게 눌려뜸")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
