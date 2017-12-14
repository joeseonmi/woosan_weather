//
//  ViewController.swift
//  Woosan
//
//  Created by joe on 2017. 11. 20..
//  Copyright © 2017년 joe. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import Lottie

class ViewController: UIViewController, CLLocationManagerDelegate,UIScrollViewDelegate {
    
    /*******************************************/
    //MARK:-          Property                 //
    /*******************************************/
    
    let shareData = UserDefaults(suiteName: "group.joe.TodayExtensionSharingDefaults")
    
    var lat:String = ""
    var lon:String = "" 
    var locationManager:CLLocationManager!
    
    
    var skyCode:String = "" {
        didSet {
            self.viewMobinWeather(today: self.skyCode)
            
            switch skyCode {
            case "SKY_M01":
                self.todaySkyImg.image = #imageLiteral(resourceName: "sky_clean")
            case "SKY_M02":
                self.todaySkyImg.image = #imageLiteral(resourceName: "sky_clean")
            case "SKY_M03":
                self.todaySkyImg.image = #imageLiteral(resourceName: "sky_clean")
            default:
                self.todaySkyImg.image = #imageLiteral(resourceName: "sky_gloomy")
            }
            
        }
    }
    
    var locationInfo:String = "현재 위치"{
        didSet{
            self.locationLabel.text = locationInfo
        }
    }
    
    
    var todayWeather:[String:String] = [:] {
        didSet{
            self.todayMaxLabel.text = todayWeather[Constants.today_key_Max]
            self.todayMinLabel.text = todayWeather[Constants.today_key_Min]
            self.todaySkyLabel.text = todayWeather[Constants.today_key_Sky]
            self.todayRainfallLabel.text = todayWeather[Constants.today_key_Rain]
            self.presentTemp.text = todayWeather[Constants.today_key_Present]
            self.humidity.text = todayWeather[Constants.today_key_Humi]
            self.windms.text = todayWeather[Constants.today_key_Wind]
            self.dust.text = todayWeather[Constants.today_key_Dust]
            if let code = todayWeather[Constants.today_key_SkyCode] {
                self.skyCode = code
            }
        }
    }
    
    
    var yesterdayWeather:[String:String] = [:] {
        didSet{
            guard let imageName:String = yesterdayWeather[Constants.yesterday_key_Sky] else { return }
            guard let imageNumber = imageName.last else { return }
            self.yesterdaySkyIcon.image = UIImage(named:"SKY_M0" + "\(imageNumber)")
            //TODO:- 코드의 이름이 어제, 오늘, 내일이 다르게 들어와서 끝번호만 따서 이미지를 호출함 나중에 더 깔끔히 고쳐보자
            self.yseterdayMinLabel.text = yesterdayWeather[Constants.yesterday_key_Min]
            self.yesterdayMaxLabel.text = yesterdayWeather[Constants.yesterday_key_Max]
        }
    }
    
    var tomorrowWeather:[String:String] = [:] {
        didSet{
            self.tomorrowSkyIcon.image = UIImage(named: tomorrowWeather[Constants.tomorrow_key_Sky] ?? "weather_default")
            self.tomorrowMinLabel.text = tomorrowWeather[Constants.tomorrow_key_Min]
            self.tomorrowMaxLabel.text = tomorrowWeather[Constants.tomorrow_key_Max]
        }
    }
    
    var afterTomorrow:[String:String] = [:] {
        didSet{
            self.aftertomorrowSkyIcon.image = UIImage(named: afterTomorrow[Constants.aftertomorrow_key_Sky] ?? "weather_default")
            self.aftertomorrowMinLabel.text = afterTomorrow[Constants.tomorrow_key_Min]
            self.aftertomorrowMaxLabel.text = afterTomorrow[Constants.tomorrow_key_Max]
        }
    }
    
    
    // outlet
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var movinImageView: UIView!
    @IBOutlet weak var weatherIconView: UIView!
    
    // Today outlet
    @IBOutlet weak var presentTemp: UILabel!
    
    @IBOutlet weak var todaySkyImg: UIImageView!
    @IBOutlet weak var windms: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var dust: UILabel!
    
    @IBOutlet weak var todayMaxLabel: UILabel!
    @IBOutlet weak var todayMinLabel: UILabel!
    @IBOutlet weak var todaySkyLabel: UILabel!
    @IBOutlet weak var todayRainfallLabel: UILabel!
    
    // Yesterday outlet
    @IBOutlet weak var yesterdaySkyIcon: UIImageView!
    @IBOutlet weak var yesterdayMaxLabel: UILabel!
    @IBOutlet weak var yseterdayMinLabel: UILabel!
    
    // tomorrow outlet
    @IBOutlet weak var tomorrowSkyIcon: UIImageView!
    @IBOutlet weak var tomorrowMaxLabel: UILabel!
    @IBOutlet weak var tomorrowMinLabel: UILabel!
    
    // aftertomorrow outlet
    @IBOutlet weak var aftertomorrowSkyIcon: UIImageView!
    @IBOutlet weak var aftertomorrowMaxLabel: UILabel!
    @IBOutlet weak var aftertomorrowMinLabel: UILabel!
    
    //scrollView
    @IBOutlet weak var todayInfoScrollView: UIScrollView!
    @IBOutlet weak var todayInfoPageControll: UIPageControl!
    
    /*******************************************/
    //MARK:-          Life Cycle               //
    /*******************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("@@@@@@@@@@@ViewdidLoad@@@@@@@@@@@@@@@")
        
        self.todayInfoScrollView.delegate = self
        self.todayInfoScrollView.showsHorizontalScrollIndicator = false
        self.todayInfoScrollView.isPagingEnabled = true
        /*
         locationManager를 인스턴스해주고, 델리게이트를 연결해준다.
         locationManager가 인스턴스 됐으니 속해있는 메소드들을 사용 할 수 있다.
         위치를 사용할 수 있도록 권한요청을 하고, 위치의 정확도를 어느정도로 할껀지 결정.
         위치정보 업데이트를 시작한다.
         */
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() //위치 권한요청
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        if let realLat = locationManager.location?.coordinate.latitude, let realLon = locationManager.location?.coordinate.longitude {
            self.lat = "\(realLat)"
            self.lon = "\(realLon)"
        }
        /*
         locationManager에서 위치정보를 가져와준다. 옵셔널타입으로 들어오기때문에 자꾸 통신상의 파라메터 오류가 떴다.
         옵셔널바인딩을 하고나서는 통신 잘 됨.
         */
        
        requestREST_3days()
        requestREST_summary()
        requestREST_minutely()
        requestREST_dust()
        
        // Lottie 부분 : 개
        let animationView = LOTAnimationView(name: "doggy")
        self.movinImageView.addSubview(animationView)
        animationView.frame.size = CGSize(width: self.movinImageView.frame.width, height: self.movinImageView.frame.height)
        animationView.loopAnimation = true
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        
        
        /* 위젯과 데이터를 공유하는 UserDefaults
        guard let shareData = UserDefaults(suiteName: "group.joe.TodayExtensionSharingDefaults") else { return }
        shareData.set(22222, forKey: "int")
        shareData.synchronize()
         */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        print("@@@@@@@@@@@ViewWillAppear@@@@@@@@@@@@@@@")
        
    }
    /*******************************************/
    //MARK:-            Func                   //
    /*******************************************/
    
    
    func viewMobinWeather(today weatherString:String) {
        // 이미 weatherMotion이 있으면 지우고 새로만들어줘야됨
        let weatherMotion = LOTAnimationView(name: weatherString)
        if weatherIconView.subviews.isEmpty == false {
            weatherMotion.removeFromSuperview()
        }
        self.weatherIconView.addSubview(weatherMotion)
        weatherMotion.frame.size = CGSize(width: self.weatherIconView.frame.width, height: self.weatherIconView.frame.height)
        weatherMotion.loopAnimation = true
        weatherMotion.contentMode = .scaleAspectFit
        weatherMotion.play()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let realLat = locationManager.location?.coordinate.latitude, let realLon = locationManager.location?.coordinate.longitude {
            self.lat = "\(realLat)"
            self.lon = "\(realLon)"
        }
    }
    
    func requestREST_3days(){
        let weatherURL = "http://apis.skplanetx.com/weather/forecast/3days"
        let parameter = [
            "version":"1",
            "lat":lat,
            "lon":lon
        ]
        
        Alamofire.request(weatherURL, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: ["appKey":"0dde6c8f-cce2-33f6-9e0d-84fcbc34e606"]).responseJSON { (response) in
            guard let data = response.data else { return }
            let watherData:JSON = JSON(data)
            let precipitation:String = watherData["weather"]["forecast3days"][0]["fcst3hour"]["precipitation"]["prob4hour"].stringValue
            self.todayWeather[Constants.today_key_Rain] = self.roundedTemperature(from: precipitation) + "%"
        }
    }
    
    func requestREST_summary() {
        let weatherURL = "http://apis.skplanetx.com/weather/summary"
        let parameter = ["version":"1",
                         "lat":lat,
                         "lon":lon]
        
        Alamofire.request(weatherURL, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: ["appKey":"0dde6c8f-cce2-33f6-9e0d-84fcbc34e606"]).responseJSON { (response) in
            guard let data = response.data else { return }
            let weatherData:JSON = JSON(data)
            
            print("=============================",weatherData)
            
            let today_min:String = weatherData["weather"]["summary"][0]["today"]["temperature"]["tmin"].stringValue
            self.todayWeather[Constants.today_key_Min] = self.roundedTemperature(from: today_min)
            let today_max:String = weatherData["weather"]["summary"][0]["today"]["temperature"]["tmax"].stringValue
            self.todayWeather[Constants.today_key_Max] = self.roundedTemperature(from: today_max)
            let today_sky:String = weatherData["weather"]["summary"][0]["today"]["sky"]["name"].stringValue
            self.todayWeather[Constants.today_key_Sky] = today_sky
            let today_skyCode:String = weatherData["weather"]["summary"][0]["today"]["sky"]["code"].stringValue
            self.todayWeather[Constants.today_key_SkyCode] = today_skyCode
            self.skyCode = today_skyCode
            
            let yest_min:String = weatherData["weather"]["summary"][0]["yesterday"]["temperature"]["tmin"].stringValue
            self.yesterdayWeather[Constants.yesterday_key_Min] = self.roundedTemperature(from: yest_min)
            let yest_max:String = weatherData["weather"]["summary"][0]["yesterday"]["temperature"]["tmax"].stringValue
            self.yesterdayWeather[Constants.yesterday_key_Max] = self.roundedTemperature(from: yest_max)
            let yest_sky:String = weatherData["weather"]["summary"][0]["yesterday"]["sky"]["code"].stringValue
            self.yesterdayWeather[Constants.yesterday_key_Sky] = yest_sky
            
            let tomo_min:String = weatherData["weather"]["summary"][0]["tomorrow"]["temperature"]["tmin"].stringValue
            self.tomorrowWeather[Constants.tomorrow_key_Min] = self.roundedTemperature(from: tomo_min)
            let tomo_max:String = weatherData["weather"]["summary"][0]["tomorrow"]["temperature"]["tmax"].stringValue
            self.tomorrowWeather[Constants.tomorrow_key_Max] = self.roundedTemperature(from: tomo_max)
            let tomo_sky:String = weatherData["weather"]["summary"][0]["tomorrow"]["sky"]["code"].stringValue
            self.tomorrowWeather[Constants.tomorrow_key_Sky] = tomo_sky
            
            let aftomo_min:String = weatherData["weather"]["summary"][0]["dayAfterTomorrow"]["temperature"]["tmin"].stringValue
            self.afterTomorrow[Constants.aftertomorrow_key_Min] = self.roundedTemperature(from: aftomo_min)
            let aftomo_max:String = weatherData["weather"]["summary"][0]["dayAfterTomorrow"]["temperature"]["tmax"].stringValue
            self.afterTomorrow[Constants.aftertomorrow_key_Max] = self.roundedTemperature(from: aftomo_max)
            let aftomo_sky:String = weatherData["weather"]["summary"][0]["dayAfterTomorrow"]["sky"]["code"].stringValue
            self.afterTomorrow[Constants.aftertomorrow_key_Sky] = aftomo_sky
            
            let cityInfo:String = weatherData["weather"]["summary"][0]["grid"]["city"].stringValue
            let countyInfo:String = weatherData["weather"]["summary"][0]["grid"]["county"].stringValue
            self.locationInfo = "\(cityInfo) " + countyInfo
            /*
             switch response.result {
             case .success(let value):
             let json = JSON(value)
             
             print("====================================",json)
             
             self.todayWeather[Constants.today_key_Max] = json["weather"]["summary"][0]["today"]["temperature"]["tmax"].string
             self.todayWeather[Constants.today_key_Min] = json["weather"]["summary"][0]["today"]["temperature"]["tmin"].string
             self.todayWeather[Constants.today_key_Sky] = json["weather"]["summary"][0]["today"]["sky"]["name"].string
             
             self.yesterdayWeather[Constants.yesterday_key_Max] = json["weather"]["summary"][0]["yesterday"]["temperature"]["tmax"].string
             self.yesterdayWeather[Constants.yesterday_key_Min] = json["weather"]["summary"][0]["yesterday"]["temperature"]["tmin"].string
             self.yesterdayWeather[Constants.yesterday_key_Sky] = json["weather"]["summary"][0]["yesterday"]["sky"]["code"].string
             
             self.tomorrowWeather[Constants.tomorrow_key_Max] = json["weather"]["summary"][0]["tomorrow"]["temperature"]["tmax"].string
             self.tomorrowWeather[Constants.tomorrow_key_Min] = json["weather"]["summary"][0]["tomorrow"]["temperature"]["tmin"].string
             self.tomorrowWeather[Constants.tomorrow_key_Sky] = json["weather"]["summary"][0]["tomorrow"]["sky"]["code"].string
             
             self.afterTomorrow[Constants.aftertomorrow_key_Max] = json["weather"]["summary"][0]["dayAfterTomorrow"]["temperature"]["tmax"].string
             self.afterTomorrow[Constants.aftertomorrow_key_Min] = json["weather"]["summary"][0]["dayAfterTomorrow"]["temperature"]["tmin"].string
             self.afterTomorrow[Constants.aftertomorrow_key_Sky] = json["weather"]["summary"][0]["dayAfterTomorrow"]["sky"]["code"].string
             
             self.locationInfo = "\(json["weather"]["summary"][0]["grid"]["city"]) "+"\(json["weather"]["summary"][0]["grid"]["county"])"
             case .failure(let error):
             print("에러:", error)
             }
             */
            
        }
    }
    
    func requestREST_minutely(){
        let weatherURL = "http://apis.skplanetx.com/weather/current/minutely"
        let parameter = ["version":"1",
                         "lat":lat,
                         "lon":lon]
        
        Alamofire.request(weatherURL, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: ["appKey":"0dde6c8f-cce2-33f6-9e0d-84fcbc34e606"]).responseJSON { (response) in
            guard let data = response.data else { return }
            let weatherData = JSON(data)
            
            print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@뚜잉",weatherData)
            let presentTemp = weatherData["weather"]["minutely"][0]["temperature"]["tc"].stringValue
            self.todayWeather[Constants.today_key_Present] = self.roundedTemperature(from: presentTemp)
            let humi = weatherData["weather"]["minutely"][0]["humidity"].stringValue
            self.todayWeather[Constants.today_key_Humi] = self.roundedTemperature(from: humi)  + "%"
            let todaywind = weatherData["weather"]["minutely"][0]["wind"]["wspd"].stringValue
            self.todayWeather[Constants.today_key_Wind] = self.roundedTemperature(from: todaywind) + "m/s"
            
        }
    }
    
    func requestREST_dust() {
        let weatherURL = "http://apis.skplanetx.com/weather/dust"
        let parameter = ["version":"1",
                        "lat":lat,
                        "lon":lon]
        Alamofire.request(weatherURL, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: ["appKey":"0dde6c8f-cce2-33f6-9e0d-84fcbc34e606"]).responseJSON { (response) in
            guard let data = response.data else { return }
            let dustData = JSON(data)
            print("미세먼지데이터잉",dustData)
            
            let dustGrade = dustData["weather"]["dust"][0]["pm10"]["grade"].stringValue
            self.todayWeather[Constants.today_key_Dust] = dustGrade
        }
    }
    
    //반올림하기
    func roundedTemperature(from temperature:String) -> String {
        var result:String = ""
        if let doubleTemperature:Double = Double(temperature) {
            let intTemperature:Int = Int(doubleTemperature.rounded())
            result = "\(intTemperature)"
        }
        return result
    }
    
    
    //ScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = self.todayInfoScrollView.contentOffset.x / self.todayInfoScrollView.frame.size.width
        self.todayInfoPageControll.currentPage = Int(page)
    }
}

//TODO:- 설정창에 API출처, 로고 넣어주어야함.
