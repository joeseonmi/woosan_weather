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
        getForecast()
        getForecastSpaceData()
        get2amData()
     
        
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
        //위치 변경됐을때
        if let realLat = locationManager.location?.coordinate.latitude, let realLon = locationManager.location?.coordinate.longitude {
            self.lat = "\(realLat)"
            self.lon = "\(realLon)"
        }
    }
    
    
    //MARK: - 기상청API로 요청하기 초단기실황조회
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
            }
        }
        time = time + "00"
        
        let appid = "9s0j9KihvN8OALwUgj4s9wV6ItX7piyt3vr0U4povDmWGRg3QNQdzeanu9xNViZNicLxqrYjI%2FDKC8wHvFUMHg%3D%3D"
        let url = "http://newsky2.kma.go.kr/service/SecndSrtpdFrcstInfoService2/ForecastGrib"
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
                case Constants.api_presentTemp :
                    let value = dataArray[i]["obsrValue"].stringValue
                    self.todayWeather[Constants.today_key_Present] = self.roundedTemperature(from: value)
                case Constants.api_humi :
                    let value = dataArray[i]["obsrValue"].stringValue
                    self.todayWeather[Constants.today_key_Humi] = value + "%"
                case Constants.api_wind :
                    let value = dataArray[i]["obsrValue"].stringValue
                    self.todayWeather[Constants.today_key_Wind] = value
               
                case Constants.api_sky :
                    let value = dataArray[i]["obsrValue"].stringValue
                    switch value {
                    case "1":
                        self.todayWeather[Constants.today_key_Sky] = "맑음"
                        self.todayWeather[Constants.today_key_SkyCode] = "SKY_D01"
                    case "2":
                        self.todayWeather[Constants.today_key_Sky] = "구름 조금"
                        self.todayWeather[Constants.today_key_SkyCode] = "SKY_D02"
                    case "3":
                        self.todayWeather[Constants.today_key_Sky] = "구름 많음"
                        self.todayWeather[Constants.today_key_SkyCode] = "SKY_D03"
                    case "4":
                        self.todayWeather[Constants.today_key_Sky] = "흐림"
                        self.todayWeather[Constants.today_key_SkyCode] = "SKY_D04"
                    default:
                        self.todayWeather[Constants.today_key_Sky] = "정보 없음"
                    }
                case Constants.api_rainform :
                    let value = dataArray[i]["obsrValue"].stringValue
                    switch value {
                    case "0":
                        self.todayWeather[Constants.today_key_Rainform] = ""
                    case "1":
                        self.todayWeather[Constants.today_key_Rainform] = "비"
                        self.todayWeather[Constants.today_key_SkyCode] = "SKY_D05"
                    case "2":
                        self.todayWeather[Constants.today_key_Rainform] = "진눈깨비"
                        self.todayWeather[Constants.today_key_SkyCode] = "SKY_D06"
                    case "3":
                        self.todayWeather[Constants.today_key_Rainform] = "눈"
                        self.todayWeather[Constants.today_key_SkyCode] = "SKY_D07"
                    default:
                        self.todayWeather[Constants.today_key_Rainform] = "정보 없음"
                    }
                default:
                    print("필요없는 값")
                }
                
            }
        }
        
    }
    
    func getForecastSpaceData() {
        let now = Date()
        let dateFommater = DateFormatter()
        let timeFommater = DateFormatter()
        let minFommater = DateFormatter()
        var nx = ""
        var ny = ""
        let yesterday = now.addingTimeInterval(-24 * 60 * 60)
        let tomorrow = now.addingTimeInterval(24 * 60 * 60)
        let dayaftertomorrow = now.addingTimeInterval(48 * 60 * 60)
        
        dateFommater.dateFormat = "yyyyMMdd"
        timeFommater.dateFormat = "HH"
        minFommater.dateFormat = "mm"
        //한국시간으로 맞춰주기
        dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
        
        let setYesterday:String = dateFommater.string(from: yesterday)
        let setTomorrow:String = dateFommater.string(from: tomorrow)
        let setDayaftertomorrow:String = dateFommater.string(from: dayaftertomorrow)
        var date:String = dateFommater.string(from: now)
        var time:String = timeFommater.string(from: now)
        let min:String = minFommater.string(from: now)
        
        print("오늘:", date,
              "어제:", setYesterday,
              "내일:", setTomorrow,
              "모레:", setDayaftertomorrow)
        
        //0200, 0500, 0800, 1100, 1400, 1700, 2000, 2300 제공
        //각 시간 10분 이후부터 API 제공
        guard let setTime = Int(time) else { return }
        if setTime < 2 {
            date = setYesterday
            time = "2300"
        } else if setTime < 5 {
            time = "0200"
        } else if setTime < 8 {
            time = "0500"
        } else if setTime < 11 {
            time = "0800"
        } else if setTime < 14 {
            time = "1100"
        } else if setTime < 17 {
            time = "1400"
        } else if setTime < 20 {
            time = "1700"
        } else if setTime < 23 {
            time = "2000"
        }
        
        if let lat = Double(self.lat), let lon = Double(self.lon) {
            nx = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["nx"]!))"
            ny = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["ny"]!))"
        }
        
    
        let appid = "9s0j9KihvN8OALwUgj4s9wV6ItX7piyt3vr0U4povDmWGRg3QNQdzeanu9xNViZNicLxqrYjI%2FDKC8wHvFUMHg%3D%3D"
        //let key = String(utf8String: appid.cString(using: String.Encoding.utf8)!)!
        let url = "http://newsky2.kma.go.kr/service/SecndSrtpdFrcstInfoService2/ForecastSpaceData"
        let parameter = ["ServiceKey":appid.removingPercentEncoding!,
                         "base_date":date,
                         "base_time":time,
                         "nx":nx,
                         "ny":ny,
                         "_type":"json",
                         "numOfRows":"999"]
        
        print("파라미터들:",date,time,nx,ny)
        
        Alamofire.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            guard let weatherData = response.data else { return }
            let data = JSON(weatherData)
            let dataArray = data["response"]["body"]["items"]["item"].arrayValue
            print("=================결과:",dataArray)
            
            for i in 0...dataArray.count - 1 {
                print("======================이름:",dataArray[i]["category"].stringValue)
                print("======================값:",dataArray[i]["fcstValue"].stringValue)
                print("======================값:",dataArray[i]["fcstDate"].stringValue)
                
                //오늘 정보 2시꺼 호출했을때
                switch dataArray[i]["fcstDate"].stringValue {
                case date:
                    switch dataArray[i]["category"].stringValue {
                    case Constants.api_rain:
                        let value = dataArray[i]["fcstValue"].stringValue
                        self.todayWeather[Constants.today_key_Rain] = value + "%"
                    case Constants.api_max:
                        let value = dataArray[i]["fcstValue"].stringValue
                        self.todayWeather[Constants.today_key_Max] = self.roundedTemperature(from: value)
                    default:
                        print("필요없는 값")
                    }
                case setTomorrow:
                    switch dataArray[i]["category"].stringValue {
                    case Constants.api_max:
                        let value = dataArray[i]["fcstValue"].stringValue
                        self.tomorrowWeather[Constants.tomorrow_key_Max] = self.roundedTemperature(from: value)
                    case Constants.api_min:
                        let value = dataArray[i]["fcstValue"].stringValue
                        self.tomorrowWeather[Constants.tomorrow_key_Min] = self.roundedTemperature(from: value)
                    case Constants.api_sky:
                        let value = dataArray[i]["fcstValue"].stringValue
                        self.tomorrowWeather[Constants.tomorrow_key_Sky] = value
                    case Constants.api_rainform:
                        let value = dataArray[i]["fcstValue"].stringValue
                        self.tomorrowWeather[Constants.tomorrow_key_Rainform] = value
                    default:
                        print("필요없는 값")
                    }
                default:
                    print("안쓰는값")
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
        let setTomorrow:String = dateFommater.string(from: tomorrow)
        var date:String = dateFommater.string(from: now)
        var time:String = timeFommater.string(from: now)
        
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
        
        let appid = "9s0j9KihvN8OALwUgj4s9wV6ItX7piyt3vr0U4povDmWGRg3QNQdzeanu9xNViZNicLxqrYjI%2FDKC8wHvFUMHg%3D%3D"
        let url = "http://newsky2.kma.go.kr/service/SecndSrtpdFrcstInfoService2/ForecastSpaceData"
        let parameter = ["ServiceKey":appid.removingPercentEncoding!,
                         "base_date":date,
                         "base_time":time,
                         "nx":nx,
                         "ny":ny,
                         "_type":"json",
                         "numOfRows":"999"]
        
        print("파라미터들:",date,time,nx,ny)
        
        Alamofire.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            guard let weatherData = response.data else { return }
            let data = JSON(weatherData)
            let dataArray = data["response"]["body"]["items"]["item"].arrayValue
            print("=================결과:",dataArray)
            
            for i in 0...dataArray.count - 1 {
                print("======================이름:",dataArray[i]["category"].stringValue)
                print("======================값:",dataArray[i]["fcstValue"].stringValue)
                print("======================값:",dataArray[i]["fcstDate"].stringValue)
                
                if setTime < 2 && dataArray[i]["fcstDate"].stringValue == setTomorrow {
                    switch dataArray[i]["category"].stringValue {
                    case Constants.api_rain:
                        let value = dataArray[i]["fcstValue"].stringValue
                        self.todayWeather[Constants.today_key_Rain] = value + "%"
                    case Constants.api_max:
                        let value = dataArray[i]["fcstValue"].stringValue
                        self.todayWeather[Constants.today_key_Max] = self.roundedTemperature(from: value)
                    case Constants.api_min:
                        let value = dataArray[i]["fcstValue"].stringValue
                        self.todayWeather[Constants.today_key_Min] = self.roundedTemperature(from: value)
                    default:
                        print("필요없는 값")
                    }
                    
                } else if dataArray[i]["fcstDate"].stringValue == date {
                    switch dataArray[i]["category"].stringValue {
                    case Constants.api_rain:
                        let value = dataArray[i]["fcstValue"].stringValue
                        self.todayWeather[Constants.today_key_Rain] = value + "%"
                    case Constants.api_max:
                        let value = dataArray[i]["fcstValue"].stringValue
                        self.todayWeather[Constants.today_key_Max] = self.roundedTemperature(from: value)
                    case Constants.api_min:
                        let value = dataArray[i]["fcstValue"].stringValue
                        self.todayWeather[Constants.today_key_Min] = self.roundedTemperature(from: value)
                    default:
                        print("필요없는 값")
                    }
                }
            }
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
}

//TODO:- 설정창에 API출처, 로고 넣어주어야함.
