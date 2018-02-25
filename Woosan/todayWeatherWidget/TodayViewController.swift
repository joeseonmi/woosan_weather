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
    var curruntWeather = todayWeather.init(curruntTemp: "00", rain: "정보 없음", weatherIcon: "default", comment: "정보 없음") {
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
                print("=============2시데이터 안불림: ",cacheData)
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
        guard let shareData = UserDefaults(suiteName: Constants.widgetShareDataKey) else { return }
        let index = shareData.integer(forKey: Constants.widgetThemeDataKey)
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
    
    //    func getForecast(base parameter:[String:String],
    //                     competed: @escaping (_ curruntData:[JSON]) -> Void) {
    //        let now = Date()
    //        let dateFommater = DateFormatter()
    //        let timeFommater = DateFormatter()
    //        dateFommater.dateFormat = "yyyyMMdd"
    //        timeFommater.dateFormat = "HH"
    //        //한국시간으로 맞춰주기
    //        dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
    //        let time:String = timeFommater.string(from: now)
    //        let url = Constants.forecastChoDangi
    //        Alamofire.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
    //            guard let weatherData = response.data else { return }
    //            let data = JSON(weatherData)
    //            let dataArray = data["response"]["body"]["items"]["item"].arrayValue
    //            competed(dataArray)
    //
    //            guard let dayNightTime = Int(time) else { return }
    //
    //            print("=================결과:",dayNightTime , "시간은 여기")
    //            if dataArray.count == 0 {
    //                self.weatherInfo[Constants.widget_key_Rain] = "강수량: - mm"
    //                self.weatherInfo[Constants.widget_key_Present] = "-"
    //                self.weatherInfo[Constants.widget_key_sky] = "정보 없음"
    //                self.weatherInfo[Constants.widget_key_skyCode] = "weather_default"
    //
    //            } else {
    //                for i in 0...dataArray.count - 1{
    //                    switch dataArray[i]["category"].stringValue {
    //                    case Constants.api_hourRain :
    //                        let value = dataArray[i]["obsrValue"].stringValue
    //                        self.weatherInfo[Constants.widget_key_Rain] = "강수량: " + value + "mm"
    //                    case Constants.api_presentTemp :
    //                        let value = dataArray[i]["obsrValue"].stringValue
    //                        self.weatherInfo[Constants.widget_key_Present] = self.roundedTemperature(from: value)
    //                    case Constants.api_sky :
    //                        let value = dataArray[i]["obsrValue"].stringValue
    //                        switch value {
    //                        case "1":
    //                            if dayNightTime > 0700 && dayNightTime < 2000 {
    //                                self.weatherInfo[Constants.widget_key_sky] = Weather.Sunny.convertName().subs
    //                                self.weatherInfo[Constants.widget_key_skyCode] = Weather.Sunny.convertName().code
    //                            } else {
    //                                self.weatherInfo[Constants.widget_key_sky] = Weather.ClearNight.convertName().subs
    //                                self.weatherInfo[Constants.widget_key_skyCode] = Weather.ClearNight.convertName().code
    //                            }
    //                        case "2":
    //                            if dayNightTime > 0700 && dayNightTime < 2000 {
    //                                self.weatherInfo[Constants.widget_key_sky] = Weather.LittleCloudy.convertName().subs
    //                                self.weatherInfo[Constants.widget_key_skyCode] = Weather.LittleCloudy.convertName().code
    //                            } else {
    //                                self.weatherInfo[Constants.widget_key_sky] = Weather.LittleCloudyNight.convertName().subs
    //                                self.weatherInfo[Constants.widget_key_skyCode] = Weather.LittleCloudyNight.convertName().code
    //                            }
    //                        case "3":
    //                            self.weatherInfo[Constants.widget_key_sky] = Weather.MoreCloudy.convertName().subs
    //                            self.weatherInfo[Constants.widget_key_skyCode] = Weather.MoreCloudy.convertName().code
    //                        case "4":
    //                            self.weatherInfo[Constants.widget_key_sky] = Weather.Cloudy.convertName().subs
    //                            self.weatherInfo[Constants.widget_key_skyCode] = Weather.Cloudy.convertName().code
    //                        default:
    //                            self.weatherInfo[Constants.widget_key_sky] = "정보 없음"
    //                        }
    //                    case Constants.api_rainform :
    //                        let value = dataArray[i]["obsrValue"].stringValue
    //                        switch value {
    //                        case "0":
    //                            self.weatherInfo[Constants.widget_key_RainForm] = ""
    //                            self.weatherInfo[Constants.widget_key_RainCode] = ""
    //                        case "1":
    //                            self.weatherInfo[Constants.widget_key_RainForm] = Weather.Rainy.convertName().subs
    //                            self.weatherInfo[Constants.widget_key_RainCode] = Weather.Rainy.convertName().code
    //                        case "2":
    //                            self.weatherInfo[Constants.widget_key_RainForm] = Weather.Sleet.convertName().subs
    //                            self.weatherInfo[Constants.widget_key_RainCode] = Weather.Sleet.convertName().code
    //                        case "3":
    //                            self.weatherInfo[Constants.widget_key_RainForm] = Weather.Snow.convertName().subs
    //                            self.weatherInfo[Constants.widget_key_RainCode] = Weather.Snow.convertName().code
    //                        default:
    //                            self.weatherInfo[Constants.widget_key_RainForm] = "정보 없음"
    //                        }
    //                    default:
    //                        print("필요없는 값")
    //                    }
    //
    //                }
    //            }
    //
    //        }
    //
    //    }
    //오늘 새벽 2시예보 부르기
    //    func get2amData(base parameter:[String:String]) {
    //        let now = Date()
    //        let dateFommater = DateFormatter()
    //        let timeFommater = DateFormatter()
    //        let minFommater = DateFormatter()
    //        let yesterday = now.addingTimeInterval(-24 * 60 * 60)
    //
    //        dateFommater.dateFormat = "yyyyMMdd"
    //        timeFommater.dateFormat = "HH"
    //        minFommater.dateFormat = "mm"
    //        //한국시간으로 맞춰주기
    //        dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
    //
    //        let setYesterday:String = dateFommater.string(from: yesterday)
    //        var date:String = dateFommater.string(from: now)
    //        var time:String = timeFommater.string(from: now)
    //        let realToday:String = dateFommater.string(from: now)
    //
    //        guard let setTime = Int(time) else { return }
    //        if setTime < 2 {
    //            date = setYesterday
    //            time = "2300"
    //        } else {
    //            time = "0200"
    //        }
    //
    //
    //        let url = Constants.forecastSpace
    //
    //        Alamofire.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
    //            guard let weatherData = response.result.value else { return }
    //            let data = JSON(weatherData)
    //            print("두시데이터 불림")
    //            let dataArray = data["response"]["body"]["items"]["item"].arrayValue
    //            if dataArray.count == 0 {
    //                self.weatherInfo[Constants.widget_key_Max] = "-"
    //                self.weatherInfo[Constants.widget_key_Min] = "-"
    //            } else {
    //                for i in 0...dataArray.count - 1 {
    //                    if setTime < 2 && dataArray[i]["fcstDate"].stringValue == realToday {
    //                        switch dataArray[i]["category"].stringValue {
    //                        case Constants.api_max:
    //                            let value = dataArray[i]["fcstValue"].stringValue
    //                            self.weatherInfo[Constants.widget_key_Max] = self.roundedTemperature(from: value)
    //                        case Constants.api_min:
    //                            let value = dataArray[i]["fcstValue"].stringValue
    //                            self.weatherInfo[Constants.widget_key_Min] = self.roundedTemperature(from: value)
    //                        default:
    //                            print("필요없는 값")
    //                        }
    //
    //                    } else if dataArray[i]["fcstDate"].stringValue == date {
    //                        switch dataArray[i]["category"].stringValue {
    //                        case Constants.api_max:
    //                            let value = dataArray[i]["fcstValue"].stringValue
    //                            self.weatherInfo[Constants.widget_key_Max] = self.roundedTemperature(from: value)
    //                        case Constants.api_min:
    //                            let value = dataArray[i]["fcstValue"].stringValue
    //                            self.weatherInfo[Constants.widget_key_Min] = self.roundedTemperature(from: value)
    //                        default:
    //                            print("필요없는 값")
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //
    //
    //    }
    //
    private func make2amAPIParameter(lat:String, lon:String) -> [String:String] {
        let now = Date()
        let dateFommater = DateFormatter()
        let timeFommater = DateFormatter()
        let minFommater = DateFormatter()
        var nx = ""
        var ny = ""
        let yesterday = now.addingTimeInterval(-24 * 60 * 60)
        dateFommater.dateFormat = "yyyyMMdd"
        timeFommater.dateFormat = "HH"
        minFommater.dateFormat = "mm"
        //한국시간으로 맞춰주기
        dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
        
        let setYesterday:String = dateFommater.string(from: yesterday)
        var date:String = dateFommater.string(from: now)
        var time:String = timeFommater.string(from: now)
        
        if let setTime = Int(time) {
            if setTime < 2 {
                date = setYesterday
                time = "2300"
            } else {
                time = "0200"
            }
        }
        
        if let lat = Double(self.lat), let lon = Double(self.lon) {
            nx = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["nx"]!))"
            ny = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["ny"]!))"
        }
        
        let appid = Constants.appKey
        let parameter = ["ServiceKey":appid.removingPercentEncoding!,
                         "base_date":date,
                         "base_time":time,
                         "nx":nx,
                         "ny":ny,
                         "_type":"json",
                         "numOfRows":"999"]
        UserDefaults.standard.setValue(parameter, forKey: Constants.parameter2am)
        return parameter
    }
    
    private func makeCurruntAPIParameter(lat:String, lon:String) -> [String:String] {
        let now = Date()
        let dateFommater = DateFormatter()
        let timeFommater = DateFormatter()
        let minFommater = DateFormatter()
        let yesterday = now.addingTimeInterval(-24 * 60 * 60)
        var nx = ""
        var ny = ""
        
        dateFommater.dateFormat = "yyyyMMdd"
        timeFommater.dateFormat = "HH"
        minFommater.dateFormat = "mm"
        
        dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
        
        var date:String = dateFommater.string(from: now)
        var time:String = timeFommater.string(from: now)
        let min:String = minFommater.string(from: now)
        let setYesterday = dateFommater.string(from: yesterday)
        
        if let lat = Double(self.lat), let lon = Double(self.lon) {
            nx = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["nx"]!))"
            ny = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["ny"]!))"
        }
        
        if Int(min)! < 30 {
            let setTime = Int(time)! - 1
            if setTime < 0 {
                date = setYesterday
                time = "23"
            } else if setTime < 10 {
                time = "0"+"\(setTime)"
            } else {
                time = "\(setTime)"
            }
        }
        time = time + "00"
        
        let appid = Constants.appKey
        let parameter = ["ServiceKey":appid.removingPercentEncoding!,
                         "base_date":date,
                         "base_time":time,
                         "nx":nx,
                         "ny":ny,
                         "_type":"json"]
        UserDefaults.standard.setValue(parameter, forKey: Constants.parameterCurrunt)
        return parameter
    }
    
    
    private func roundedTemperature(from temperature:String) -> String {
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
