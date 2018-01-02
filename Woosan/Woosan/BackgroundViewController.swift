//
//  BackgroundViewController.swift
//  Woosan
//
//  Created by joe on 2017. 12. 10..
//  Copyright © 2017년 joe. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import Photos

class BackgroundViewController: UIViewController {
    
    /*******************************************/
    //MARK:-          Property                 //
    /*******************************************/
    @IBOutlet weak var collectionView: UICollectionView!
    var bgImagesData:[String] = []
    
    /*******************************************/
    //MARK:-          Life Cycle               //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "배경화면"
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: "BGCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BGCollectionViewCell")

        getImages()
 
    }

    
    /*******************************************/
    //MARK:-          Func                     //
    /*******************************************/
    
    func getImages() {
        Database.database().reference().child("BGimages").child("doggy").observeSingleEvent(of: .value) { (data) in
            guard let imagesData = data.value as? [String] else { print("없졍!")
                return }
            self.bgImagesData = imagesData
            self.collectionView.reloadData()
        }
    }
    
}


/*******************************************/
//MARK:-          Extension                //
/*******************************************/

extension BackgroundViewController : UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.bgImagesData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BGCollectionViewCell", for: indexPath) as! BGCollectionViewCell
        cell.bgthum.kf.indicatorType = .activity
        if let url = URL(string: self.bgImagesData[indexPath.row]) {
            cell.bgthum.kf.setImage(with: url)
        }
        return cell
    }
}

extension BackgroundViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailView:BGDetailViewController = storyboard?.instantiateViewController(withIdentifier: "BGDetailViewController") as! BGDetailViewController
        detailView.imageURL = self.bgImagesData[indexPath.row]
        self.present(detailView, animated: true, completion: nil)
    }
}

extension BackgroundViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.collectionView.frame.width / 2 ) - 8
        let height = width / 3 * 4
        return CGSize(width: width, height: height)
    }
    
}



