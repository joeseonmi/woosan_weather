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
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var rainLabel: UIImageView!
    @IBOutlet weak var rainTextLabel: UILabel!
    @IBOutlet weak var dustLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var presenTemp: UILabel!
    @IBOutlet weak var maxTemp: UILabel!
    @IBOutlet weak var minTemp: UILabel!
    
    @IBAction func tapExtention(_ sender: UITapGestureRecognizer) {
        print("tap!")
//        self.reloadDatas()
        let url = NSURL(string: "woosan://")
        extensionContext?.open(url! as URL, completionHandler: nil)
    }
    
    @IBOutlet weak var themeCharacter: UIImageView!
  
    
    let image:[String] = ["doggy",
                          "catty"]
    var curruntDust:String = "" {
        didSet {
            loadImage(text: curruntDust)
        }
    }
    
    var lat:String = ""
    var lon:String = ""
    var locationInfo:String = "" {
        didSet {
            self.locationLabel.text = locationInfo
        }
    }
    var cityName = "" {
        didSet {
            let now = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd-HH:00"
            let time = formatter.string(from: now)
            guard let checkParameter = UserDefaults(suiteName: DataShare.widgetShareDataKey) else { return }
            let parameter = checkParameter.dictionary(forKey: DataShare.dustDataKey) as! [String:String]
            
            if parameter["time"] == time {
                print("미세먼지 캐시데이터")
                self.dustLabel.text = "미세먼지: " + parameter["dust10Value"]! + " | " + parameter["dustComment"]!
                self.curruntDust = self.curruntDustImage(text: parameter["dustComment"]!)
            } else {
                dustAPIController.shared.todayDustInfo(cityName) { (response) in
                    self.dustLabel.text = "미세먼지: " + response.dust10Value + " | " + response.dustComment
                    self.curruntDust = self.curruntDustImage(text: response.dustComment)
                }
            }
//            dustAPIController.shared.todayDustInfo(cityName) { (response) in
//                self.dustLabel.text = "미세먼지: " + response.dust10Value + " | " + response.dustComment
//            }
        }
    }
    var cacheCurruntWeather:[String:String] = [:] {
        didSet {
            UserDefaults.standard.set(cacheCurruntWeather, forKey: Constants.dataCurrunt)
        }
    }
    
    var cacheMaxMin:[String:String] = [:] {
        didSet {
            UserDefaults.standard.set(cacheMaxMin, forKey: Constants.data2am)
        }
    }
    
    var maxmin = todayMaxMin.init(max: "-", min: "-") {
        didSet{
            self.maxTemp.text = maxmin.max
            self.minTemp.text = maxmin.min
        }
    }
    var curruntWeather = todayWeather.init(curruntTemp: "00", rain: "정보 없음", weatherIcon: "default", comment: "좋음") {
        didSet {
            self.rainTextLabel.text = curruntWeather.rain
            self.presenTemp.text = curruntWeather.curruntTemp
            self.weatherImageView.image = UIImage(named:curruntWeather.weatherIcon)
            self.commentLabel.text = curruntWeather.comment
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
            
            if UserDefaults.standard.dictionary(forKey: Constants.parameter2am) == nil {
                UserDefaults.standard.set(["none":"none"], forKey: Constants.parameter2am)
            }
            let cacheParameter2am:[String:String] = UserDefaults.standard.dictionary(forKey: Constants.parameter2am) as! [String : String]
            let newParameter2am = WidgetAPIController.shared.make2amAPIParameter(lat: lat, lon: lon)
            
            if cacheParameter2am != newParameter2am {
                print("2시데이터 불림")
                WidgetAPIController.shared.maxMinTemp(lat: lat, lon: lon, completed: { (maxmintemperature) in
                    self.maxmin = maxmintemperature
                    self.cacheMaxMin[Constants.cache_max] = maxmintemperature.max
                    self.cacheMaxMin[Constants.cache_min] = maxmintemperature.min
                })
            } else {
                guard let cacheData = UserDefaults.standard.dictionary(forKey: Constants.data2am) else { return }
                print("=============2시 캐시데이터 불림: ",cacheData)
                self.maxTemp.text = cacheData[Constants.cache_max] as? String
                self.minTemp.text = cacheData[Constants.cache_min] as? String
            }
            
            if UserDefaults.standard.dictionary(forKey: Constants.parameterCurrunt) == nil {
                UserDefaults.standard.set(["none":"none"], forKey: Constants.parameterCurrunt)
            }
            let cacheParameterCurrunt:[String:String] = UserDefaults.standard.dictionary(forKey: Constants.parameterCurrunt) as! [String : String]
            let newParameterCurrunt = WidgetAPIController.shared.makeCurruntAPIParameter(lat: lat, lon: lon)
            if cacheParameterCurrunt != newParameterCurrunt {
                WidgetAPIController.shared.curruntWeather(lat: lat, lon: lon, completed: { (info) in
                    self.curruntWeather = info
                    self.cacheCurruntWeather[Constants.cache_curruntTemp] = info.curruntTemp
                    self.cacheCurruntWeather[Constants.cache_icon] = info.weatherIcon
                    self.cacheCurruntWeather[Constants.cache_comment] = info.comment
                    self.cacheCurruntWeather[Constants.cache_rain] = info.rain
                })
            } else {
                guard let cacheData = UserDefaults.standard.dictionary(forKey: Constants.dataCurrunt) else { return }
                print("=============캐시데이터 불림: ",cacheData)
                self.rainTextLabel.text = cacheData[Constants.cache_rain] as? String
                self.presenTemp.text = cacheData[Constants.cache_curruntTemp] as? String
                let image = cacheData[Constants.cache_icon] as! String
                self.weatherImageView.image = UIImage(named: image)
                self.commentLabel.text = cacheData[Constants.cache_comment] as? String
            }
            
            
        }
        
        if let coordinate = locationManager.location{
            convertAddress(from: coordinate)
        }
        
        //원 앱과 데이터 통신을 하는 방법으로 Userdefaults가 있다.
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
//        SE버전은 강수확률이 안보이게 설정했다.
//                let widthSize = self.bgView.frame.width
//                if widthSize <= 304.0 {
//                    self.rainLabel.isHidden = true
//                    self.rainTextLabel.isHidden = true
//                }
    }
    
    /*******************************************/
    //MARK:-              Func                 //
    /*******************************************/
    
    func reloadDatas() {
        let locationManager = CLLocationManager()
        if let realLat = locationManager.location?.coordinate.latitude,
            let realLon = locationManager.location?.coordinate.longitude{
            self.lat = "\(realLat)"
            self.lon = "\(realLon)"
            
            WidgetAPIController.shared.maxMinTemp(lat: lat, lon: lon, completed: { (maxmintemperature) in
                self.maxmin = maxmintemperature
                self.cacheMaxMin[Constants.cache_max] = maxmintemperature.max
                self.cacheMaxMin[Constants.cache_min] = maxmintemperature.min
            })
            
            WidgetAPIController.shared.curruntWeather(lat: lat, lon: lon, completed: { (info) in
                self.curruntWeather = info
                self.cacheCurruntWeather[Constants.cache_curruntTemp] = info.curruntTemp
                self.cacheCurruntWeather[Constants.cache_icon] = info.weatherIcon
                self.cacheCurruntWeather[Constants.cache_comment] = info.comment
                self.cacheCurruntWeather[Constants.cache_rain] = info.rain
            })
            
        }
        
    }
    func loadImage(text:String){
        guard let shareData = UserDefaults(suiteName: Constants.widgetShareDataKey) else { return }
        let index = shareData.integer(forKey: Constants.widgetThemeDataKey)
        self.themeCharacter.image = UIImage(named: "\(self.image[index])" + "_" + text)
        shareData.synchronize()
    }
    
    func curruntDustImage(text:String) -> String {
        switch text {
        case "좋음": return "clear"
        case "보통": return "soso"
        case "나쁨": return "bad"
        case "매우 나쁨": return "soBad"
        default:return "clear"
        }
    }
    
    func convertAddress(from coordinate:CLLocation) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(coordinate) { (placemarks, error) in
            if let someError = error {
                print("에러가 있는데여:" ,someError)
                return
            }
            guard let placemark = placemarks?.first else { return }
            if let state = placemark.administrativeArea,
                let city = placemark.locality,
                let subLocality = placemark.subLocality {
                self.locationInfo = "\(state) " + "\(city) " + subLocality
                self.cityName = state
            }
            return
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

