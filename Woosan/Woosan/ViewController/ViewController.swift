import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import Lottie

class ViewController: UIViewController, CLLocationManagerDelegate,UIScrollViewDelegate {
    
    /*******************************************/
    //MARK:-          Property                 //
    /*******************************************/
    
    let shareData = UserDefaults(suiteName: DataShare.widgetShareDataKey)
    var themeName = Theme.doggy.convertName() {
        didSet{
            self.viewMovinAnimal(animal: self.themeName)
        }
    }
    
    var lat:String = ""
    var lon:String = ""
    var locationManager:CLLocationManager!
    var dateformatter = DateFormatter()
    var now = Date()
    var country:String = "" {
        didSet{
            //TODO: :::나중에 수정 - 해외API연결
            if country != "대한민국" && country != "South Korea" {
                let nextVC:notiPopup = storyboard?.instantiateViewController(withIdentifier: "onlyCanUseInKorea") as! notiPopup
                present(nextVC, animated: true, completion: nil)
            }
        }
    }
    var state:String = "" {
        didSet{
            /*
             1. 데이터 있나 확인(위젯에 먼저확인했는지)
             2. 시간저장해두고 같은 시간이면 호출 안하게
             */
            dustAPIController.shared.todayDustInfo(state) { (response) in
                self.dust.text = response.dust10Value + " | " + response.dustComment
            }
        }
    }
    
    var skyCode:String = "" {
        didSet {
            self.viewMobinWeather(today: self.skyCode)
            switch skyCode {
            case Weather.Sunny.convertName().code,
                 Weather.LittleCloudy.convertName().code,
                 Weather.MoreCloudy.convertName().code :
                dateformatter.dateFormat = "HH"
                let dayOrNight = dateformatter.string(from: self.now)
                guard let time = Int(dayOrNight) else { return }
                if time > 07 && time < 20 {
                    self.todaySkyImg.image = #imageLiteral(resourceName: "sky_clean")
                } else {
                    self.todaySkyImg.image = #imageLiteral(resourceName: "sky_gloomy")
                }
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
            if let tempRainsub = todayWeather[Constants.today_key_Rainform] {
                self.todaySkyLabel.text = tempRainsub
            } else {
                self.todaySkyLabel.text = todayWeather[Constants.today_key_Sky]
            }
            self.todayRainfallLabel.text = todayWeather[Constants.today_key_Rain]
            self.presentTemp.text = todayWeather[Constants.today_key_Present]
            self.humidity.text = todayWeather[Constants.today_key_Humi]
            self.windms.text = todayWeather[Constants.today_key_Wind]
            if let tempRain = todayWeather[Constants.today_key_RainCode] {
                self.skyCode = tempRain
            } else {
                guard let tempSky = todayWeather[Constants.today_key_SkyCode] else { return }
                self.skyCode = tempSky
            }
        }
    }
    
    //날짜, 시간, 온도, 하늘, 강수형태, 강수확률
    var yesterParseData:[String:[String:String]] = [:] {
        didSet{
            self.collectionView.reloadData()
        }
    }
    var todayParseData:[String:ForecastWeather] = [:]{
        didSet{
            self.collectionView.reloadData()
        }
    }
    var tomorrowParseData:[String:ForecastWeather] = [:]{
        didSet{
            self.collectionView.reloadData()
        }
    }
    var afterParseData:[String:ForecastWeather] = [:]{
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
    
    //scrollView
    @IBOutlet weak var todayInfoScrollView: UIScrollView!
    @IBOutlet weak var todayInfoPageControll: UIPageControl!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var dustBtn: UIButton!
    var firstRunning:Bool = true
    var denied:Bool = false
    /*******************************************/
    //MARK:-          Life Cycle               //
    /*******************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dustBtn.isHidden = true
        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@: viewDidLoad")
        //정보 들어오기전 아무것도 안뜨게 초기화
        self.locationLabel.text = ""
        self.todayRainfallLabel.text = ""
        self.todaySkyLabel.text = ""
        
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
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("----------------------pass")
            self.firstRunning = false
        case .denied, .restricted:
            print("----------------------denied")
            self.denied = true
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        }
       
        if !firstRunning {
            guard let coordinate = locationManager.location else { return }
            self.convertAddress(from: coordinate)
            
            
            if let realLat = locationManager.location?.coordinate.latitude,
                let realLon = locationManager.location?.coordinate.longitude {
                self.lat = "\(realLat)"
                self.lon = "\(realLon)"
                
                WeatherAPIController.shared.curruntWeather(lat: self.lat, lon: self.lon, completed: { (curruntWeather) in
                    print("불려쓰요://", curruntWeather)
                    self.humidity.text = curruntWeather.humi
                    self.todaySkyLabel.text = curruntWeather.sky
                    self.presentTemp.text = curruntWeather.curruntTemp
                    self.todayRainfallLabel.text = curruntWeather.rain
                    self.windms.text = curruntWeather.wind
                    self.skyCode = curruntWeather.icon
                })
                
                WeatherAPIController.shared.maxMinTemp(lat: self.lat, lon: self.lon, completed: { (maxminData) in
                    self.todayMaxLabel.text = maxminData.max
                    self.todayMinLabel.text = maxminData.min
                })
               
                WeatherAPIController.shared.getForecast(lat: self.lat, lon: self.lon) { (response) in
                    print("ajdididididi: ",response.keys.sorted())
                    guard let todayData = response["today"],
                        let tomorrowData = response["tomorrow"],
                     let after = response["after"] else { return }
                    self.todayParseData = todayData
                    self.tomorrowParseData = tomorrowData
                    self.afterParseData = after
                }

            }
        }
        
        
        
        //didBecomeActive상태일때, Lottie를 재생하기 위한 noti
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: nil) { (noti) in
            self.viewMobinWeather(today: self.skyCode)
            self.viewMovinAnimal(animal: self.themeName)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@: viewWillAppear")
        
        //현재 테마 체크
        let themeValue = UserDefaults.standard.integer(forKey: DataShare.selectedThemeKey)
        guard let theme = Theme(rawValue: themeValue) else { return }
        self.themeName = theme.convertName()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@: viewDidAppear")
        
        if denied {
            self.alert(alertTitle: "위치 정보 사용 불가", alertmessage: "설정에서 위치 정보 사용을 허용해주세요!")
        }
        
        self.viewMobinWeather(today: self.skyCode)
        self.viewMovinAnimal(animal: self.themeName)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        //나갈때 노티 지워주기
    }
    
    /*******************************************/
    //MARK:-            Func                   //
    /*******************************************/
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@: ChangeStatus")
        
        if firstRunning {
            guard let coordinate = locationManager.location else { return }
            self.convertAddress(from: coordinate)
            
            if let realLat = locationManager.location?.coordinate.latitude,
                let realLon = locationManager.location?.coordinate.longitude {
                self.lat = "\(realLat)"
                self.lon = "\(realLon)"

                WeatherAPIController.shared.curruntWeather(lat: self.lat, lon: self.lon, completed: { (curruntWeather) in
                    print("불려쓰요://", curruntWeather)
                    self.humidity.text = curruntWeather.humi
                    self.todaySkyLabel.text = curruntWeather.sky
                    self.presentTemp.text = curruntWeather.curruntTemp
                    self.todayRainfallLabel.text = curruntWeather.rain
                    self.windms.text = curruntWeather.wind
                    self.skyCode = curruntWeather.icon
                })
                
                WeatherAPIController.shared.maxMinTemp(lat: self.lat, lon: self.lon, completed: { (maxminData) in
                    self.todayMaxLabel.text = maxminData.max
                    self.todayMinLabel.text = maxminData.min
                })
                
                WeatherAPIController.shared.getForecast(lat: self.lat, lon: self.lon) { (response) in
                    print("ajdididididi: ",response.keys.sorted())
                    guard let todayData = response["today"],
                        let tomorrowData = response["tomorrow"],
                        let after = response["after"] else { return }
                    self.todayParseData = todayData
                    self.tomorrowParseData = tomorrowData
                    self.afterParseData = after
                }
                
            }
        }
    }
    
    func alert(alertTitle:String, alertmessage: String){
        let alert:UIAlertController = UIAlertController.init(title: alertTitle, message: alertmessage, preferredStyle: .alert)
        let alertAction:UIAlertAction = UIAlertAction.init(title: "확인", style: .cancel, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    
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
                self.state = state
            }
            
            if let country = placemark.country {
                self.country = country
            }
        }
        
    }
    
    func errorAlert(subTitle:String, subMessage:String) {
        let alert:UIAlertController = UIAlertController.init(title: subTitle, message: subMessage, preferredStyle: .alert)
        let alertAction = UIAlertAction.init(title: "확인", style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
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
            return self.tomorrowParseData.count
        case 3:
            return self.afterParseData.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "forecastCell", for: indexPath) as! forecastCollectionViewCell
        switch indexPath.section {
        case 0:
//            let time = self.yesterParseData.keys.sorted()
//            guard let data = self.yesterParseData[time[indexPath.row]] else { return cell }
//            let cellData = cell.weatherData(dataPerHour: data)
//            cell.forecastHour.text = "\(cellData.forecastTime)시"
//            cell.forecastTemp.text = cellData.temperature
//            cell.rainPopLable.text = cellData.rainPOP + "%"
//            cell.weatherImageView.image = UIImage(named:cellData.icon)
            return cell
        case 1:
            let time = self.todayParseData.keys.sorted()
            guard let data = self.todayParseData[time[indexPath.row]] else { return cell }
            let cellData = cell.weatherData(dataPerHour: data)
            if indexPath.row == 0 {
                cell.forecastHour.text = "오늘 " + cellData.forecastTime
            } else {
                cell.forecastHour.text = cellData.forecastTime
            }
            cell.forecastTemp.text = cellData.temperature
            cell.rainPopLable.text = cellData.rainPOP
            cell.weatherImageView.image = UIImage(named:cellData.icon)
            cell.timeBGView.backgroundColor = UIColor.init(red: 232/255, green: 166/255, blue: 166/255, alpha: 0.1)
            return cell
        case 2:
            let time = self.tomorrowParseData.keys.sorted()
            guard let data = self.tomorrowParseData[time[indexPath.row]] else { return cell }
            let cellData = cell.weatherData(dataPerHour: data)
            if indexPath.row == 0 {
                cell.forecastHour.text = "내일 " + cellData.forecastTime
            } else {
                cell.forecastHour.text = cellData.forecastTime
            }
            cell.forecastTemp.text = cellData.temperature
            cell.rainPopLable.text = cellData.rainPOP
            cell.weatherImageView.image = UIImage(named:cellData.icon)
            cell.timeBGView.backgroundColor = UIColor(red: 109/255, green: 164/255, blue: 198/255, alpha: 0.1)
            return cell
        case 3:
            let time = self.afterParseData.keys.sorted()
            guard let data = self.afterParseData[time[indexPath.row]] else { return cell }
            let cellData = cell.weatherData(dataPerHour: data)
            if indexPath.row == 0 {
                cell.forecastHour.text = "모레 " + cellData.forecastTime
            } else {
                cell.forecastHour.text = cellData.forecastTime
            }
            cell.forecastTemp.text = cellData.temperature
            cell.rainPopLable.text = cellData.rainPOP
            cell.weatherImageView.image = UIImage(named: cellData.icon)
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

