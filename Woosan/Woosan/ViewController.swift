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
    var dateformatter = DateFormatter()
    var now = Date()
    
    var skyCode:String = "" {
        didSet {
            self.viewMobinWeather(today: self.skyCode)
            
            switch skyCode {
            case "SKY_D01", "SKY_D02","SKY_D03" :
                dateformatter.dateFormat = "HH"
                var dayOrNight = dateformatter.string(from: self.now)
                guard let time = Int(dayOrNight) else { return }
                if time > 07 && time <= 20 {
                    self.todaySkyImg.image = #imageLiteral(resourceName: "sky_clean")
                }
                self.todaySkyImg.image = #imageLiteral(resourceName: "sky_gloomy")
            default:
                self.todaySkyImg.image = #imageLiteral(resourceName: "sky_gloomy")
            }
            
        }
    }
    
    var locationInfo:String = "현재 위치"{
        didSet{
            self.locationLabel.text = self.locationInfo
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
    
    //날짜, 시간, 온도, 하늘, 강수형태, 강수확률
    var yesterParseData:[String:[String:String]] = [:] {
        didSet{
            self.collectionView.reloadData()
        }
    }
    var todayParseData:[String:[String:String]] = [:]{
        didSet{
            self.collectionView.reloadData()
        }
    }
    var tommorowParseData:[String:[String:String]] = [:]{
        didSet{
            self.collectionView.reloadData()
        }
    }
    var afterParseData:[String:[String:String]] = [:]{
        didSet{
            self.collectionView.reloadData()
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
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    /*******************************************/
    //MARK:-          Life Cycle               //
    /*******************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("@@@@@@@@@@@ViewdidLoad@@@@@@@@@@@@@@@")
        
        self.collectionView.register(UINib(nibName: "forecastCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "forecastCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.isPagingEnabled = false
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
        
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
            
            getForecast()
            getForecastSpaceData()
            get2amData()
            getPM10()
        }
        /*
         locationManager에서 위치정보를 가져와준다. 옵셔널타입으로 들어오기때문에 자꾸 통신상의 파라메터 오류가 떴다.
         옵셔널바인딩을 하고나서는 통신 잘 됨.
         */
        
        
        if let coordinate = self.locationManager.location {
            convertAddress(from: coordinate)
        }
        
        
        /* 위젯과 데이터를 공유하는 UserDefaults
         guard let shareData = UserDefaults(suiteName: "group.joe.TodayExtensionSharingDefaults") else { return }
         shareData.set(22222, forKey: "int")
         shareData.synchronize()
         */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("@@@@@@@@@@@ViewWillAppear@@@@@@@@@@@@@@@")
        
        if let code:String = todayWeather[Constants.today_key_SkyCode]{
            self.viewMobinWeather(today: code)
        }
        self.viewMovinAnimal(animal: "doggy")
    }
    /*******************************************/
    //MARK:-            Func                   //
    /*******************************************/
    
    func viewMovinAnimal(animal name:String) {
        self.movinImageView.layer.sublayers = nil
        let animationView = LOTAnimationView(name: name)
        self.movinImageView.addSubview(animationView)
        animationView.frame.size = CGSize(width: self.movinImageView.frame.width, height: self.movinImageView.frame.height)
        animationView.loopAnimation = true
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        
    }
    
    func viewMobinWeather(today weatherString:String) {
        // 이미 weatherMotion이 있으면 지우고 새로만들어줘야됨
        self.weatherIconView.layer.sublayers = nil
        let weatherMotion = LOTAnimationView(name: weatherString)
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
        
        
        //TODO: 12시에 실행해보기
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
        
        let appid = "Nz1AZqAjQYidfKtkqDExWFKmAbO%2Bn3kcfRZd7Ut%2FzMpTaTH67raoJo599zfgUTDip9IGUXa%2FZpnkCCn7p%2BXd5w%3D%3D"
        let url = "http://newsky2.kma.go.kr/service/SecndSrtpdFrcstInfoService2/ForecastGrib"
        let parameter = ["ServiceKey":appid.removingPercentEncoding!,
                         "base_date":date,
                         "base_time":time,
                         "nx":nx,
                         "ny":ny,
                         "_type":"json"]
        
        print("파라미터들(초단기실황):",date,time,nx,ny)
        
        Alamofire.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            guard let weatherData = response.result.value else { return }
            let data = JSON(weatherData)
            let dataArray = data["response"]["body"]["items"]["item"].arrayValue
            guard let dayNightTime = Int(time) else { return }
//            print("=================초단기실황 결과:",data)
            
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
                        if dayNightTime > 0700 && dayNightTime < 2000 {
                            self.todayWeather[Constants.today_key_Sky] = "맑음"
                            self.todayWeather[Constants.today_key_SkyCode] = "SKY_D01"
                        } else {
                            self.todayWeather[Constants.today_key_Sky] = "맑음"
                            self.todayWeather[Constants.today_key_SkyCode] = "SKY_D08"
                        }
                    case "2":
                        if dayNightTime > 0700 && dayNightTime < 2000 {
                            self.todayWeather[Constants.today_key_Sky] = "구름 조금"
                            self.todayWeather[Constants.today_key_SkyCode] = "SKY_D02"
                        } else {
                            self.todayWeather[Constants.today_key_Sky] = "구름 조금"
                            self.todayWeather[Constants.today_key_SkyCode] = "SKY_D09"
                        }
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
        let realDate:String = dateFommater.string(from: now)
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
        } else if setTime >= 23 {
            time = "2300"
        }
        
        if let lat = Double(self.lat), let lon = Double(self.lon) {
            nx = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["nx"]!))"
            ny = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["ny"]!))"
        }
        
        
        let appid = "Nz1AZqAjQYidfKtkqDExWFKmAbO%2Bn3kcfRZd7Ut%2FzMpTaTH67raoJo599zfgUTDip9IGUXa%2FZpnkCCn7p%2BXd5w%3D%3D"
        let url = "http://newsky2.kma.go.kr/service/SecndSrtpdFrcstInfoService2/ForecastSpaceData"
        let parameter = ["ServiceKey":appid.removingPercentEncoding!,
                         "base_date":date,
                         "base_time":time,
                         "nx":nx,
                         "ny":ny,
                         "_type":"json",
                         "numOfRows":"999"]
        
        print("파라미터들:",date,time,nx,ny)
        
        var yesterDict:[String:String] = [:]
        var todayDict:[String:String] = [:]
        var tomorrowDict:[String:String] = [:]
        var afterDict:[String:String] = [:]
        
        
        Alamofire.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            guard let weatherData = response.result.value else { return }
            let data = JSON(weatherData)
            let dataArray = data["response"]["body"]["items"]["item"].arrayValue
            
            //어제 날짜인 정보를 불러옵니다
            let yesterFroecastArray = dataArray.filter({ (dic) -> Bool in
                let yesterday:String = dic["fcstDate"].stringValue
                return yesterday == setYesterday
            })
            for i in yesterFroecastArray {
                var fcsttime:String = i["fcstTime"].stringValue
                fcsttime = i["fcstTime"].stringValue
                yesterDict["\(i["category"].stringValue)"] = "\(i["fcstValue"].stringValue)"
                yesterDict["fcstTime"] = fcsttime
                yesterDict["fcstDate"] = i["fcstDate"].stringValue
                self.yesterParseData[fcsttime] = yesterDict
            }
            print("어제 정보: ",self.yesterParseData)
            
            //오늘 날짜인 예보들을 불러옵니다.
            let todayForecastArray = dataArray.filter({ (dic) -> Bool in
                let today:String = dic["fcstDate"].stringValue
                return today == realDate
            })
//            print("오늘예보만 보여주세요: ",todayForecastArray)
            for i in todayForecastArray {
                var fcsttime:String = i["fcstTime"].stringValue
                fcsttime = i["fcstTime"].stringValue
                todayDict["\(i["category"].stringValue)"] = "\(i["fcstValue"].stringValue)"
                todayDict["fcstTime"] = fcsttime
                todayDict["fcstDate"] = i["fcstDate"].stringValue
                self.todayParseData[fcsttime] = todayDict
            }
            print("오늘 예보: ",self.todayParseData)
            
            
            //내일 날짜인 예보들을 불러옵니다.
            let tomorrowForecastArray = dataArray.filter({ (dic) -> Bool in
                let tomorrow:String = dic["fcstDate"].stringValue
                return tomorrow == setTomorrow
            })
            
            for i in tomorrowForecastArray {
                var fcsttime:String = i["fcstTime"].stringValue
                fcsttime = i["fcstTime"].stringValue
                tomorrowDict["\(i["category"].stringValue)"] = "\(i["fcstValue"].stringValue)"
                tomorrowDict["fcstTime"] = fcsttime
                tomorrowDict["fcstDate"] = i["fcstDate"].stringValue
                self.tommorowParseData[fcsttime] = tomorrowDict
            }
            print("내일 예보:", self.tommorowParseData)
            
            //모레 날짜인 예보들을 불러옵니다.
            let afterForecastArray = dataArray.filter({ (dic) -> Bool in
                let after:String = dic["fcstDate"].stringValue
                return after == setDayaftertomorrow
            })
            
            for i in afterForecastArray {
                var fcsttime:String = i["fcstTime"].stringValue
                fcsttime = i["fcstTime"].stringValue
                afterDict["\(i["category"].stringValue)"] = "\(i["fcstValue"].stringValue)"
                afterDict["fcstTime"] = fcsttime
                afterDict["fcstDate"] = i["fcstDate"].stringValue
                self.afterParseData[fcsttime] = afterDict
            }
            print("모레 예보:", self.afterParseData)
        }
        
    }
    
    //오늘 새벽 2시예보 부르기 -> 오늘의 최저/최고온도가 2시에 발표되기때문에 label에 띄우려면 갖구와야댐
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
        
        let appid = "Nz1AZqAjQYidfKtkqDExWFKmAbO%2Bn3kcfRZd7Ut%2FzMpTaTH67raoJo599zfgUTDip9IGUXa%2FZpnkCCn7p%2BXd5w%3D%3D"
        let url = "http://newsky2.kma.go.kr/service/SecndSrtpdFrcstInfoService2/ForecastSpaceData"
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
            let dataArray = data["response"]["body"]["items"]["item"].arrayValue
            
            for i in 0...dataArray.count - 1 {
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
    
    //미세먼지
    func getPM10() {
        
        let url = "http://openapi.airkorea.or.kr/openapi/services/rest/ArpltnInforInqireSvc/getCtprvnRltmMesureDnsty"
        let appid = "Nz1AZqAjQYidfKtkqDExWFKmAbO%2Bn3kcfRZd7Ut%2FzMpTaTH67raoJo599zfgUTDip9IGUXa%2FZpnkCCn7p%2BXd5w%3D%3D"
        let parameter = ["sidoName":"경기",
                         "ServiceKey":appid.removingPercentEncoding!,
                         "_returnType":"json",
                         "searchCondition":"DAILY",
                         "numOfRows": "999",
                         "ver":"1.3"]
        
        Alamofire.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            guard let responsData = response.value else { return }
            let pm10Data = JSON(responsData)
            print("미세먼지=-----:", pm10Data)
            
        }
        
    }
    
    //위치로, 지역이름 알아오기
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

extension ViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.yesterParseData.count
        case 1:
            return self.todayParseData.count
        case 2:
            return self.tommorowParseData.count
        case 3:
            return self.afterParseData.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "forecastCell", for: indexPath) as! forecastCollectionViewCell
        //TODO: - 여기 극혐인부분 수정할수있는지~_~ 혼돈의카오스다..........
        switch indexPath.section {
        case 0:
            let time = self.yesterParseData.keys.sorted()
            guard let data = self.yesterParseData[time[indexPath.row]] else { return cell }
            guard let fcstTime = data["fcstTime"] else { return cell }
            cell.forecastHour.text = "\(Int(fcstTime)! / 100)시"
            cell.forecastTemp.text = data["T3H"]
            if data["PTY"] == "0"{
                guard let sky = data["SKY"] else { return cell }
                cell.weatherImageView.image = UIImage(named: "SKY_M0" + sky) ?? #imageLiteral(resourceName: "weather_default")
            }else{
                guard let rain = data["PTY"] else { return cell }
                cell.weatherImageView.image = UIImage(named: "RAIN_M0" + rain) ?? #imageLiteral(resourceName: "weather_default")
            }
            return cell
        case 1:
            let time = self.todayParseData.keys.sorted()
            guard let data = self.todayParseData[time[indexPath.row]] else { return cell }
            guard let fcstTime = data["fcstTime"] else { return cell }
            if indexPath.row == 0 {
                cell.forecastHour.text = "오늘 " + "\(Int(fcstTime)! / 100)시"
            } else {
                cell.forecastHour.text = "\(Int(fcstTime)! / 100)시"
            }
            cell.forecastTemp.text = data["T3H"]
            if data["PTY"] == "0"{
                guard let sky = data["SKY"] else { return cell }
                cell.weatherImageView.image = UIImage(named: "SKY_M0" + sky) ?? #imageLiteral(resourceName: "weather_default")
            }else{
                guard let rain = data["PTY"] else { return cell }
                cell.weatherImageView.image = UIImage(named: "RAIN_M0" + rain) ?? #imageLiteral(resourceName: "weather_default")
            }
            cell.timeBGView.backgroundColor = UIColor.init(red: 232/255, green: 166/255, blue: 166/255, alpha: 0.1)
            return cell
        case 2:
            let time = self.tommorowParseData.keys.sorted()
                guard let data = self.tommorowParseData[time[indexPath.row]] else { return cell }
                guard let fcstTime = data["fcstTime"] else { return cell }
                if indexPath.row == 0 {
                    cell.forecastHour.text = "내일 "+"\(Int(fcstTime)! / 100)시"
                } else {
                    cell.forecastHour.text = "\(Int(fcstTime)! / 100)시"
                }
                cell.forecastTemp.text = data["T3H"]
                if data["PTY"] == "0"{
                    guard let sky = data["SKY"] else { return cell }
                    cell.weatherImageView.image = UIImage(named: "SKY_M0" + sky) ?? #imageLiteral(resourceName: "weather_default")
                }else{
                    guard let rain = data["PTY"] else { return cell }
                    cell.weatherImageView.image = UIImage(named: "RAIN_M0" + rain) ?? #imageLiteral(resourceName: "weather_default")
            }
             cell.timeBGView.backgroundColor = UIColor(red: 109/255, green: 164/255, blue: 198/255, alpha: 0.1)
            return cell
        case 3:
            let time = self.afterParseData.keys.sorted()
                guard let data = self.afterParseData[time[indexPath.row]] else { return cell }
                guard let fcstTime = data["fcstTime"] else { return cell }
                if indexPath.row == 0 {
                    cell.forecastHour.text = "모레 "+"\(Int(fcstTime)! / 100)시"
                } else {
                    cell.forecastHour.text = "\(Int(fcstTime)! / 100)시"
                }
                cell.forecastTemp.text = data["T3H"]
                if data["PTY"] == "0"{
                    guard let sky = data["SKY"] else { return cell }
                    cell.weatherImageView.image = UIImage(named: "SKY_M0" + sky) ?? #imageLiteral(resourceName: "weather_default")
                }else{
                    guard let rain = data["PTY"] else { return cell }
                    cell.weatherImageView.image = UIImage(named: "RAIN_M0" + rain) ?? #imageLiteral(resourceName: "weather_default")
                }
             cell.timeBGView.backgroundColor = UIColor(red: 251/255, green: 207/255, blue: 8/255, alpha: 0.1)
            return cell
        default:
            return cell
        }
    }
}

extension ViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

//TODO:- 설정창에 API출처, 로고 넣어주어야함.
