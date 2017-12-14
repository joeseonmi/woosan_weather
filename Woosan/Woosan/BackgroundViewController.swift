//
//  BackgroundViewController.swift
//  Woosan
//
//  Created by joe on 2017. 12. 10..
//  Copyright © 2017년 joe. All rights reserved.
//

import UIKit
import Firebase

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
        
        //이미지를 넣을검니다
        let url = self.bgImagesData[indexPath.row]
        if let thumbnailURL = URL(string: url) {
            //URL만들어주고
            let session = URLSession(configuration: .default)
            //URL을 다운로드하고 지지고볶고하려면 URL세션을 만들어야댐
            let download = session.dataTask(with: thumbnailURL) { (data, response, error) in
                if let dataError = error {
                    print("이미지 불러오기 에러: ",dataError)
                }
                if let dataResponse = response {
                    print("이미지 불러오기 응답: ",dataResponse)
                    guard let realData = data else { return }
                    DispatchQueue.main.sync {
                        cell.bgthum.image = UIImage(data: realData)
                    }
                }else{
                    print("이미지가 엄성")
                }
            }
            download.resume()
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



