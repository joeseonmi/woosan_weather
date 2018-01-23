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
    
    @IBOutlet weak var themeCharacter: UIImageView!
    let image:[String] = ["widgetDoggyhead",
                          "widgetCattyhead"]
    
    var lat:String = ""
    var lon:String = ""
    var locationInfo:String = "" {
        didSet {
            self.locationLabel.text = locationInfo
        }
    }
    var weatherInfo:[String:String] = [:] {
        didSet{
            self.rainTextLabel.text = self.weatherInfo[Constants.widget_key_Rain]
            self.presenTemp.text = self.weatherInfo[Constants.widget_key_Present]
            self.minTemp.text = self.weatherInfo[Constants.widget_key_Min]
            self.maxTemp.text = self.weatherInfo[Constants.widget_key_Max]
            if self.weatherInfo[Constants.widget_key_RainCode] == "" {
                if let image = self.weatherInfo[Constants.widget_key_skyCode] {
                    self.weatherImageView.image = UIImage(named: image)
                }
            } else {
                if let image = self.weatherInfo[Constants.widget_key_RainCode] {
                    self.weatherImageView.image = UIImage(named: image)
                }
            }
            if self.weatherInfo[Constants.widget_key_RainForm] == "" {
                if let comment = self.weatherInfo[Constants.widget_key_sky] {
                    self.commentLabel.text = comment
                }
            } else {
                if let comment = self.weatherInfo[Constants.widget_key_RainForm] {
                    self.commentLabel.text = comment
                }
            }
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
            
            get2amData()
            getForecast()
        }
        if let coordinate = locationManager.location{
            convertAddress(from: coordinate)
        }
        
        
        //원 앱과 데이터 통신을 하는 방법으로 Userdefaults가 있다.
        self.loadImage()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.loadImage()
        
        //SE버전은 강수확률이 안보이게 설정했다.
//        let widthSize = self.bgView.frame.width
//        if widthSize <= 304.0 {
//            self.rainLabel.isHidden = true
//            self.rainTextLabel.isHidden = true
//        }
    }
    
    /*******************************************/
    //MARK:-              Func                 //
    /*******************************************/
    
    func loadImage(){
        guard let shareData = UserDefaults(suiteName: "group.devjoe.TodayExtensionSharingDefaults") else { return }
        let index = shareData.integer(forKey: "Theme")
        self.themeCharacter.image = UIImage(named: self.image[index])
        shareData.synchronize()
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
            }
            return
        }
        
    }
    
    func getForecast() {
        let now = Date()
        let dateFommater = DateFormatter()
        let timeFommater = DateFormatter()
        let minFommater = DateFormatter()
        var nx = ""
        var ny = ""
        
        dateFommater.dateFormat = "yyyyMMdd"
        timeFommater.dateFormat = "HH"
        minFommater.dateFormat = "mm"
        
        dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
        
        let date:String = dateFommater.string(from: now)
        var time:String = timeFommater.string(from: now)
        let min:String = minFommater.string(from: now)
        
        if let lat = Double(self.lat), let lon = Double(self.lon) {
            nx = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["nx"]!))"
            ny = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["ny"]!))"
        }
        
        
        
        if Int(min)! < 30 {
            let setTime = Int(time)! - 1
            if setTime < 10 {
                time = "0"+"\(setTime)"
            } else {
                time = "\(setTime)"
                time = time + "00"
            }
        }
        time = time + "00"
        
        let appid = Constants.appKey
        let url = Constants.forecastChoDangi
        let parameter = ["ServiceKey":appid.removingPercentEncoding!,
                         "base_date":date,
                         "base_time":time,
                         "nx":nx,
                         "ny":ny,
                         "_type":"json"]
        
        print("파라미터들:",date,time,nx,ny)
        
        Alamofire.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            guard let weatherData = response.data else { return }
            let data = JSON(weatherData)
            let dataArray = data["response"]["body"]["items"]["item"].arrayValue
            print("=================결과:",dataArray)
            
            for i in 0...dataArray.count - 1{
                switch dataArray[i]["category"].stringValue {
                case Constants.api_hourRain :
                    let value = dataArray[i]["obsrValue"].stringValue
                    self.weatherInfo[Constants.widget_key_Rain] = "강수량: " + value + "mm"
                case Constants.api_presentTemp :
                    let value = dataArray[i]["obsrValue"].stringValue
                    self.weatherInfo[Constants.widget_key_Present] = self.roundedTemperature(from: value)
                case Constants.api_sky :
                    let value = dataArray[i]["obsrValue"].stringValue
                    switch value {
                    case "1":
                        self.weatherInfo[Constants.widget_key_sky] = Weather.Sunny.convertName().subs
                        self.weatherInfo[Constants.widget_key_skyCode] = Weather.Sunny.convertName().code
                    case "2":
                        self.weatherInfo[Constants.widget_key_sky] = Weather.LittleCloudy.convertName().subs
                        self.weatherInfo[Constants.widget_key_skyCode] = Weather.LittleCloudy.convertName().code
                    case "3":
                        self.weatherInfo[Constants.widget_key_sky] = Weather.MoreCloudy.convertName().subs
                        self.weatherInfo[Constants.widget_key_skyCode] = Weather.MoreCloudy.convertName().code
                    case "4":
                        self.weatherInfo[Constants.widget_key_sky] = Weather.Cloudy.convertName().subs
                        self.weatherInfo[Constants.widget_key_skyCode] = Weather.Cloudy.convertName().code
                    default:
                        self.weatherInfo[Constants.widget_key_sky] = "정보 없음"
                    }
                case Constants.api_rainform :
                    let value = dataArray[i]["obsrValue"].stringValue
                    switch value {
                    case "0":
                        self.weatherInfo[Constants.widget_key_RainForm] = ""
                        self.weatherInfo[Constants.widget_key_RainCode] = ""
                    case "1":
                        self.weatherInfo[Constants.widget_key_RainForm] = Weather.Rainy.convertName().subs
                        self.weatherInfo[Constants.widget_key_RainCode] = Weather.Rainy.convertName().code
                    case "2":
                        self.weatherInfo[Constants.widget_key_RainForm] = Weather.Sleet.convertName().subs
                        self.weatherInfo[Constants.widget_key_RainCode] = Weather.Sleet.convertName().code
                    case "3":
                        self.weatherInfo[Constants.widget_key_RainForm] = Weather.Snow.convertName().subs
                        self.weatherInfo[Constants.widget_key_RainCode] = Weather.Snow.convertName().code
                    default:
                        self.weatherInfo[Constants.widget_key_RainForm] = "정보 없음"
                    }
                default:
                    print("필요없는 값")
                }
                
            }
            
            
        }
        
    }
    //오늘 새벽 2시예보 부르기
    func get2amData() {
        let now = Date()
        let dateFommater = DateFormatter()
        let timeFommater = DateFormatter()
        let minFommater = DateFormatter()
        var nx = ""
        var ny = ""
        let yesterday = now.addingTimeInterval(-24 * 60 * 60)
        let tomorrow = now.addingTimeInterval(24 * 60 * 60)
        
        dateFommater.dateFormat = "yyyyMMdd"
        timeFommater.dateFormat = "HH"
        minFommater.dateFormat = "mm"
        //한국시간으로 맞춰주기
        dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
        
        let setYesterday:String = dateFommater.string(from: yesterday)
        var date:String = dateFommater.string(from: now)
        var time:String = timeFommater.string(from: now)
        var realToday:String = dateFommater.string(from: now)
        
        guard let setTime = Int(time) else { return }
        if setTime < 2 {
            date = setYesterday
            time = "2300"
        } else {
            time = "0200"
        }
        
        if let lat = Double(self.lat), let lon = Double(self.lon) {
            nx = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["nx"]!))"
            ny = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["ny"]!))"
        }
        
        let appid = Constants.appKey
        let url = Constants.forecastSpace
        let parameter = ["ServiceKey":appid.removingPercentEncoding!,
                         "base_date":date,
                         "base_time":time,
                         "nx":nx,
                         "ny":ny,
                         "_type":"json",
                         "numOfRows":"999"]
        
        print("파라미터들(두시데이터):",date,time,nx,ny)
        
        Alamofire.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            guard let weatherData = response.result.value else { return }
            let data = JSON(weatherData)
            print("ㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇ:", data)
            let dataArray = data["response"]["body"]["items"]["item"].arrayValue
            
            for i in 0...dataArray.count - 1 {
                if setTime < 2 && dataArray[i]["fcstDate"].stringValue == realToday {
                    switch dataArray[i]["category"].stringValue {
                    case Constants.api_max:
                        let value = dataArray[i]["fcstValue"].stringValue
                        self.weatherInfo[Constants.widget_key_Max] = self.roundedTemperature(from: value)
                    case Constants.api_min:
                        let value = dataArray[i]["fcstValue"].stringValue
                        self.weatherInfo[Constants.widget_key_Min] = self.roundedTemperature(from: value)
                    default:
                        print("필요없는 값")
                    }
                    
                } else if dataArray[i]["fcstDate"].stringValue == date {
                    switch dataArray[i]["category"].stringValue {
                    case Constants.api_max:
                        let value = dataArray[i]["fcstValue"].stringValue
                        self.weatherInfo[Constants.widget_key_Max] = self.roundedTemperature(from: value)
                    case Constants.api_min:
                        let value = dataArray[i]["fcstValue"].stringValue
                        self.weatherInfo[Constants.widget_key_Min] = self.roundedTemperature(from: value)
                    default:
                        print("필요없는 값")
                    }
                }
            }
        }
        
        
    }
    
    
    func roundedTemperature(from temperature:String) -> String {
        var result:String = ""
        if let doubleTemperature:Double = Double(temperature) {
            let intTemperature:Int = Int(doubleTemperature.rounded())
            result = "\(intTemperature)"
        }
        return result
    }
    
    //MARK: - 위도경도 좌표변환뻘짓 함수. 기상청이 제공한 소스를 swift 버전으로 수정해본것.
    func convertGrid(code:String, v1:Double, v2:Double) -> [String:Double] {
        // LCC DFS 좌표변환을 위한 기초 자료
        let RE = 6371.00877 // 지구 반경(km)
        let GRID = 5.0 // 격자 간격(km)
        let SLAT1 = 30.0 // 투영 위도1(degree)
        let SLAT2 = 60.0 // 투영 위도2(degree)
        let OLON = 126.0 // 기준점 경도(degree)
        let OLAT = 38.0 // 기준점 위도(degree)
        let XO = 43 // 기준점 X좌표(GRID)
        let YO = 136 // 기1준점 Y좌표(GRID)
        //
        //
        // LCC DFS 좌표변환 ( code : "toXY"(위경도->좌표, v1:위도, v2:경도), "toLL"(좌표->위경도,v1:x, v2:y) )
        //
        let DEGRAD = Double.pi / 180.0
        let RADDEG = 180.0 / Double.pi
        
        let re = RE / GRID
        let slat1 = SLAT1 * DEGRAD
        let slat2 = SLAT2 * DEGRAD
        let olon = OLON * DEGRAD
        let olat = OLAT * DEGRAD
        
        var sn = tan(Double.pi * 0.25 + slat2 * 0.5) / tan(Double.pi * 0.25 + slat1 * 0.5)
        sn = log(cos(slat1) / cos(slat2)) / log(sn)
        var sf = tan(Double.pi * 0.25 + slat1 * 0.5)
        sf = pow(sf, sn) * cos(slat1) / sn
        var ro = tan(Double.pi * 0.25 + olat * 0.5)
        ro = re * sf / pow(ro, sn)
        var rs:[String:Double] = [:]
        var theta = v2 * DEGRAD - olon
        if (code == "toXY") {
            
            rs["lat"] = v1
            rs["lng"] = v2
            var ra = tan(Double.pi * 0.25 + (v1) * DEGRAD * 0.5)
            ra = re * sf / pow(ra, sn)
            if (theta > Double.pi) {
                theta -= 2.0 * Double.pi
            }
            if (theta < -Double.pi) {
                theta += 2.0 * Double.pi
            }
            theta *= sn
            rs["nx"] = floor(ra * sin(theta) + Double(XO) + 0.5)
            rs["ny"] = floor(ro - ra * cos(theta) + Double(YO) + 0.5)
        }
        else {
            rs["nx"] = v1
            rs["ny"] = v2
            let xn = v1 - Double(XO)
            let yn = ro - v2 + Double(YO)
            let ra = sqrt(xn * xn + yn * yn)
            if (sn < 0.0) {
                sn - ra
            }
            var alat = pow((re * sf / ra), (1.0 / sn))
            alat = 2.0 * atan(alat) - Double.pi * 0.5
            
            if (abs(xn) <= 0.0) {
                theta = 0.0
            }
            else {
                if (abs(yn) <= 0.0) {
                    let theta = Double.pi * 0.5
                    if (xn < 0.0){
                        xn - theta
                    }
                }
                else{
                    theta = atan2(xn, yn)
                }
            }
            let alon = theta / sn + olon
            rs["lat"] = alat * RADDEG
            rs["lng"] = alon * RADDEG
        }
        return rs
    }
    
    
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
