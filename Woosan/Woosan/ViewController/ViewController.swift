import UIKit
import CoreLocation
import Lottie
import Toaster

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
            let now = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd-HH:00"
            let time = formatter.string(from: now)
            guard let checkParameter = UserDefaults(suiteName: DataShare.widgetShareDataKey) else { return }
            let parameter = checkParameter.dictionary(forKey: DataShare.dustDataKey) as! [String:String]
            if parameter["time"] == time {
                print("미세먼지 캐시데이터: ", parameter)
                self.dust.text = parameter["dust10Value"]! + " | " + parameter["dustComment"]!
            } else {
                dustAPIController.shared.todayDustInfo(state) { (response) in
                    self.dust.text = response.dust10Value + " | " + response.dustComment
                }
            }
            /*
             1. 데이터 있나 확인(위젯에 먼저확인했는지)
             2. 시간저장해두고 같은 시간이면 호출 안하게
             */
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
    @IBAction func dustInfoIcon(_ sender: UIButton) {
        let toast:Toast = Toast(text: "출처:환경부/한국환경공단\n데이터는 실시간 관측된 자료이며 측정소 현지 사정이나 \n데이터의 수신상태에 따라 미수신될 수 있습니다.", duration: Delay.long)
        toast.show()
    }
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
                
                self.getCrrunt(lat: self.lat, lon: self.lon) { [weak self] item in
                    self?.humidity.text = item.humi
                    self?.todaySkyLabel.text = item.sky
                    self?.presentTemp.text = item.curruntTemp
                    self?.todayRainfallLabel.text = item.rain
                    self?.windms.text = item.wind
                    self?.skyCode = item.icon
                }
                
                WeatherAPIController.shared.maxMinTemp(lat: self.lat, lon: self.lon,
                                                       completed: { [weak self] maxminData in
                    self?.todayMaxLabel.text = maxminData.max
                    self?.todayMinLabel.text = maxminData.min
                })
               
                WeatherAPIController.shared.getForecast(lat: self.lat, lon: self.lon) { [weak self] response in
                    guard let todayData = response["today"],
                        let tomorrowData = response["tomorrow"],
                     let after = response["after"] else { return }
                    self?.todayParseData = todayData
                    self?.tomorrowParseData = tomorrowData
                    self?.afterParseData = after
                }

            }
        }
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
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
    
    private func getCrrunt(lat: String, lon: String,
                           completeHandler: @escaping (_ item: CurruntWeather) -> Void) {
        WeatherAPIAdapter.request(target: .curruntWeater(lat: lat, lon: lon),
                                  success: { succ in
                                    do {
                                        let data = try JSONDecoder().decode(WeatherResponse.self, from: succ.data)
//                                        let curruntWeather = data.response.body.items
                                        
                                        completeHandler(data.response.body.items.convertCurrunt())
                                    } catch let err {
                                        print("parsingError: ", err)
                                    }
        },
                                  error: { _ in
                                    print("서버 통신 오류")
        },
                                  failure: { _ in
                                    print("Moya error")
        })
    }
    
    @objc func applicationDidBecomeActive() {
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

                self.getCrrunt(lat: self.lat, lon: self.lon) { [weak self] item in
                    self?.humidity.text = item.humi
                    self?.todaySkyLabel.text = item.sky
                    self?.presentTemp.text = item.curruntTemp
                    self?.todayRainfallLabel.text = item.rain
                    self?.windms.text = item.wind
                    self?.skyCode = item.icon
                }
                
                WeatherAPIController.shared.maxMinTemp(lat: self.lat, lon: self.lon, completed: { [weak self] maxminData in
                    self?.todayMaxLabel.text = maxminData.max
                    self?.todayMinLabel.text = maxminData.min
                })
                
                WeatherAPIController.shared.getForecast(lat: self.lat, lon: self.lon) { [weak self]response in
                    guard let todayData = response["today"],
                        let tomorrowData = response["tomorrow"],
                        let after = response["after"] else { return }
                    self?.todayParseData = todayData
                    self?.tomorrowParseData = tomorrowData
                    self?.afterParseData = after
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

