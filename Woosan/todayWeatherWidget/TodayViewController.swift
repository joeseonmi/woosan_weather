//
//  TodayViewController.swift
//  todayWeatherWidget
//
//  Created by joe on 2017. 12. 2..
//  Copyright © 2017년 joe. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire
import SwiftyJSON
import CoreLocation


class TodayViewController: UIViewController, NCWidgetProviding,CLLocationManagerDelegate {
    
    /*******************************************/
    //MARK:-      Property & Outlet            //
    /*******************************************/
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var rainLabel: UIImageView!
    
    @IBOutlet weak var rainTextLabel: UILabel!
    @IBOutlet weak var dustLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var presenTemp: UILabel!
    @IBOutlet weak var maxTemp: UILabel!
    @IBOutlet weak var minTemp: UILabel!
    
    var lat:String = ""
    var lon:String = ""
    var weatherInfo:[String:String] = [:] {
        didSet{
            self.dustLabel.text = weatherInfo[Constants.widget_key_Dust]
        }
    }
    /*******************************************/
    //MARK:-          Life Cycle               //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        if let realLat = locationManager.location?.coordinate.latitude,
            let realLon = locationManager.location?.coordinate.longitude{
            self.lat = "\(realLat)"
            self.lon = "\(realLon)"
            
        }
        requset_dust()
        
        /*
        guard let shareData = UserDefaults(suiteName: "group.joe.TodayExtensionSharingDefaults") else {return}
        print("=================================================",shareData.value(forKey: "int"))
        shareData.synchronize()
        원 앱과 데이터 통신을 하는 방법으로 Userdefaults가 있다.
         */
        
    }
 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        //SE버전은 강수확률이 안보이게 설정했다.
        let widthSize = self.bgView.frame.width
        if widthSize <= 304.0 {
            self.rainLabel.isHidden = true
            self.rainTextLabel.isHidden = true
        }
    }
   
    /*******************************************/
    //MARK:-              Func                 //
    /*******************************************/
    
    func requset_dust() {
        let weatherURL = "http://apis.skplanetx.com/weather/dust"
        let parameter = ["version":"1",
                         "lat":lat,
                         "lon":lon]
        
        Alamofire.request(weatherURL, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: ["appKey":"0dde6c8f-cce2-33f6-9e0d-84fcbc34e606"]).responseJSON { (response) in
            guard let data = response.data else { return }
            let dustData = JSON(data)
            print("데이터 있쓰요?!", dustData)
            
            let dustGrade = dustData["weather"]["dust"][0]["pm10"]["grade"].stringValue
            self.weatherInfo[Constants.widget_key_Dust] = "미세먼지 " + dustGrade
            
        }
    }
    
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
