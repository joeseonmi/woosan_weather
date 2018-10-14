//
//  WidgetAPIController.swift
//  todayWeatherWidget
//
//  Created by joe on 2018. 2. 25..
//  Copyright © 2018년 joe. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class WeatherAPIController {

    static let shared = WeatherAPIController()

    func curruntWeather(lat:String,lon:String ,completed: @escaping (_ todayinfo: CurruntWeather) -> Void ) {
        print("현재 날씨 네트워킹!")
        getCurrunt(base: makeCurruntAPIParameter(lat: lat, lon: lon)) { (dataArray) in
            let now = Date()
            let dateFommater = DateFormatter()
            let timeFommater = DateFormatter()
            dateFommater.dateFormat = "yyyyMMdd"
            timeFommater.dateFormat = "HH"
            //한국시간으로 맞춰주기
            dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
            let time:String = timeFommater.string(from: now)
            let temp = CurruntWeather.empty
           
            var weatherInfo:[String:String] = [:]
            
            if dataArray.count == 0 {
                completed(temp)
            } else {
                for i in 0...dataArray.count - 1{
                    switch dataArray[i]["category"].stringValue {
                    case Constants.api_hourRain :
                        let value = dataArray[i]["obsrValue"].stringValue
                        weatherInfo[Constants.today_key_Rain] = "강수량: " + value + "mm"
                    case Constants.api_presentTemp :
                        let value = dataArray[i]["obsrValue"].stringValue
                        weatherInfo[Constants.today_key_Present] = self.roundedTemperature(from: value)
                    case Constants.api_humi :
                        let value = dataArray[i]["obsrValue"].stringValue
                        weatherInfo[Constants.today_key_Humi] = value + "%"
                    case Constants.api_wind :
                        let value = dataArray[i]["obsrValue"].stringValue
                        weatherInfo[Constants.today_key_Wind] = value
                    case Constants.api_sky :
                        guard let dayNightTime = Int(time) else { return }
                        print("=================결과:",dayNightTime , "시간은 여기")
                        let value = dataArray[i]["obsrValue"].stringValue
                        switch value {
                        case "1":
                            if dayNightTime > 07 && dayNightTime < 20 {
                                weatherInfo[Constants.today_key_Sky] = Weather.Sunny.convertName().subs
                                weatherInfo[Constants.today_key_SkyCode] = Weather.Sunny.convertName().code
                            } else {
                                weatherInfo[Constants.today_key_Sky] = Weather.ClearNight.convertName().subs
                                weatherInfo[Constants.today_key_SkyCode] = Weather.ClearNight.convertName().code
                            }
                        case "2":
                            if dayNightTime > 07 && dayNightTime < 20 {
                                weatherInfo[Constants.today_key_Sky] = Weather.LittleCloudy.convertName().subs
                                weatherInfo[Constants.today_key_SkyCode] = Weather.LittleCloudy.convertName().code
                            } else {
                                weatherInfo[Constants.today_key_Sky] = Weather.LittleCloudyNight.convertName().subs
                                weatherInfo[Constants.today_key_SkyCode] = Weather.LittleCloudyNight.convertName().code
                            }
                        case "3":
                            weatherInfo[Constants.today_key_Sky] = Weather.MoreCloudy.convertName().subs
                            weatherInfo[Constants.today_key_SkyCode] = Weather.MoreCloudy.convertName().code
                        case "4":
                            weatherInfo[Constants.today_key_Sky] = Weather.Cloudy.convertName().subs
                            weatherInfo[Constants.today_key_SkyCode] = Weather.Cloudy.convertName().code
                        default:
                            weatherInfo[Constants.today_key_Sky] = "정보 없음"
                        }
                    case Constants.api_rainform :
                        let value = dataArray[i]["obsrValue"].stringValue
                        switch value {
                        case "0":
                            weatherInfo[Constants.today_key_Rainform] = ""
                            weatherInfo[Constants.today_key_RainCode] = ""
                        case "1":
                            weatherInfo[Constants.today_key_Rainform] = Weather.Rainy.convertName().subs
                            weatherInfo[Constants.today_key_RainCode] = Weather.Rainy.convertName().code
                        case "2":
                            weatherInfo[Constants.today_key_Rainform] = Weather.Sleet.convertName().subs
                            weatherInfo[Constants.today_key_RainCode] = Weather.Sleet.convertName().code
                        case "3":
                            weatherInfo[Constants.today_key_Rainform] = Weather.Snow.convertName().subs
                            weatherInfo[Constants.today_key_RainCode] = Weather.Snow.convertName().code
                        default:
                            weatherInfo[Constants.today_key_Rainform] = "정보 없음"
                        }
                    default:
                        print("필요없는 값")
                    }
                }
                
                
                var icon = ""
                if weatherInfo[Constants.today_key_RainCode] == "" {
                    guard let image = weatherInfo[Constants.today_key_SkyCode] else { return }
                    icon = image
                } else {
                    guard let image = weatherInfo[Constants.today_key_RainCode] else { return }
                    icon = image
                }

                var weatherComment = ""
                if weatherInfo[Constants.today_key_Rainform] == "" {
                    guard let comment = weatherInfo[Constants.today_key_Sky] else { return }
                    weatherComment = comment
                } else {
                    guard let comment = weatherInfo[Constants.today_key_Rainform] else { return }
                    weatherComment = comment
                }

                guard let curruntTemp = weatherInfo[Constants.today_key_Present],
                    let rainpop = weatherInfo[Constants.today_key_Rain],
                    let todayHumi = weatherInfo[Constants.today_key_Humi],
                    let todayWind = weatherInfo[Constants.today_key_Wind] else { return }


                let todayWeaterInfo:CurruntWeather = CurruntWeather(curruntTemp: curruntTemp,
                                                                    rain: rainpop,
                                                                    wind: todayWind,
                                                                    humi: todayHumi,
                                                                    sky: weatherComment,
                                                                    icon: icon)
                completed(todayWeaterInfo)
            }
        }
    }

    func maxMinTemp(lat:String, lon:String, completed: @escaping (_ temper:MaxMinData)->Void) {
        getForecast(base: make2amAPIParameter(lat: lat, lon: lon)) { (dataArray) in
            print("두시데이터 네트워킹!")
            let now = Date()
            let dateFommater = DateFormatter()
            let timeFommater = DateFormatter()
            let minFommater = DateFormatter()
            let yesterday = now.addingTimeInterval(-24 * 60 * 60)

            dateFommater.dateFormat = "yyyyMMdd"
            timeFommater.dateFormat = "HH"
            minFommater.dateFormat = "mm"
            //한국시간으로 맞춰주기
            dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)

            let setYesterday:String = dateFommater.string(from: yesterday)
            var date:String = dateFommater.string(from: now)
            var time:String = timeFommater.string(from: now)
            let realToday:String = dateFommater.string(from: now)

            guard let setTime = Int(time) else { return }
            if setTime < 2 {
                date = setYesterday
                time = "2300"
            } else {
                time = "0200"
            }
            let temp = MaxMinData(max: "00", min: "00")
            var weatherInfo:[String:String] = [:]
            if dataArray.count == 0 {
                completed(temp)
            } else {
                for i in 0...dataArray.count - 1 {
                    if setTime < 2 && dataArray[i]["fcstDate"].stringValue == realToday {
                        switch dataArray[i]["category"].stringValue {
                        case Constants.api_max:
                            let value = dataArray[i]["fcstValue"].stringValue
                            weatherInfo[Constants.today_key_Max] = self.roundedTemperature(from: value)
                        case Constants.api_min:
                            let value = dataArray[i]["fcstValue"].stringValue
                            weatherInfo[Constants.today_key_Min] = self.roundedTemperature(from: value)
                        default:
                            print("필요없는 값")
                        }

                    } else if dataArray[i]["fcstDate"].stringValue == date {
                        switch dataArray[i]["category"].stringValue {
                        case Constants.api_max:
                            let value = dataArray[i]["fcstValue"].stringValue
                            weatherInfo[Constants.today_key_Max] = self.roundedTemperature(from: value)
                        case Constants.api_min:
                            let value = dataArray[i]["fcstValue"].stringValue
                            weatherInfo[Constants.today_key_Min] = self.roundedTemperature(from: value)
                        default:
                            print("필요없는 값")
                        }
                    }
                }
            }
            guard let maxdata = weatherInfo[Constants.today_key_Max],
                let mindata = weatherInfo[Constants.today_key_Min] else { return }
            let maxMindata:MaxMinData = MaxMinData(max: maxdata, min: mindata)
            completed(maxMindata)
        }

    }

    func getForecast(lat:String, lon:String, completed: @escaping (_ temper:[String:[String:ForecastWeather]])->Void)  {
        getForecast(base: makeForecastAPIParameter(lat: lat, lon: lon)) { (dataArray) in
    
            let now = Date()
            let dateFommater = DateFormatter()
            let timeFommater = DateFormatter()
            let minFommater = DateFormatter()
           
            let tomorrow = now.addingTimeInterval(24 * 60 * 60)
            let dayaftertomorrow = now.addingTimeInterval(48 * 60 * 60)
            
            dateFommater.dateFormat = "yyyyMMdd"
            timeFommater.dateFormat = "HH"
            minFommater.dateFormat = "mm"
            //한국시간으로 맞춰주기
            dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
            
            let setTomorrow:String = dateFommater.string(from: tomorrow)
            let setDayaftertomorrow:String = dateFommater.string(from: dayaftertomorrow)
            let realDate:String = dateFommater.string(from: now)
            
            var totalForecast:[String:[String:ForecastWeather]] = [:]
            
            var todayDict:[String:ForecastWeather] = [:]
            var tomorrowDict:[String:ForecastWeather] = [:]
            var afterDict:[String:ForecastWeather] = [:]
            
            //오늘 날짜인 예보들을 불러옵니다.
            let todayForecastArray = dataArray.filter({ (dic) -> Bool in
                let today:String = dic["fcstDate"].stringValue
                return today == realDate
            })
            //            print("오늘예보만 보여주세요: ",todayForecastArray)
            var tempDic:[String:String] = [:]
            for i in todayForecastArray {
                let fcsttime:String = i["fcstTime"].stringValue
                let category = i["category"].stringValue
                let value = i["fcstValue"].stringValue
                tempDic[category] = value
                let todayForecast = ForecastWeather.init(forecastTime: fcsttime, forecast: tempDic)
                todayDict[fcsttime] = todayForecast
            }
//            print("오늘 예보: ",todayDict)
            //내일 날짜인 예보들을 불러옵니다.
            let tomorrowForecastArray = dataArray.filter({ (dic) -> Bool in
                let tomorrow:String = dic["fcstDate"].stringValue
                return tomorrow == setTomorrow
            })
            var tomorrowtempDic:[String:String] = [:]
            for i in tomorrowForecastArray {
                let fcsttime:String = i["fcstTime"].stringValue
                let category = i["category"].stringValue
                let value = i["fcstValue"].stringValue
                tomorrowtempDic[category] = value
                let afterForecast = ForecastWeather.init(forecastTime: fcsttime, forecast: tomorrowtempDic)
                tomorrowDict[fcsttime] = afterForecast
            }
//            print("내일 예보:", tomorrowDict)
            
            //모레 날짜인 예보들을 불러옵니다.
            let afterForecastArray = dataArray.filter({ (dic) -> Bool in
                let after:String = dic["fcstDate"].stringValue
                return after == setDayaftertomorrow
            })
            var aftertempDic:[String:String] = [:]
            for i in afterForecastArray {
                let fcsttime:String = i["fcstTime"].stringValue
                let category = i["category"].stringValue
                let value = i["fcstValue"].stringValue
                aftertempDic[category] = value
                let afterForecast = ForecastWeather.init(forecastTime: fcsttime, forecast: aftertempDic)
                afterDict[fcsttime] = afterForecast
            }
//            print("모레 예보:", afterDict)
            totalForecast["today"] = todayDict
            totalForecast["tomorrow"] = tomorrowDict
            totalForecast["after"] = afterDict
//            print("토탈: ", totalForecast)
            completed(totalForecast)
        }
        
    }
    
    private func getCurrunt(base parameter:[String:String],
                             competed: @escaping (_ curruntData:[JSON]) -> Void) {
        let url = DataShare.forecastChoDangi
        Alamofire.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: nil)
            .responseJSON { (response) in
                switch response.result {
                case .success :
                    guard let weatherData = response.data else { return }
                    let data = JSON(weatherData)
                    let dataArray = data["response"]["body"]["items"]["item"].arrayValue
                    competed(dataArray)
                case .failure( _) : break
                }
        }
    }
    
    private func getForecast(base parameter:[String:String], completed: @escaping (_ value:[JSON])-> Void) {
        let url = DataShare.forecastSpace
        Alamofire.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            guard let weatherData = response.result.value else { return }
            let data = JSON(weatherData)
            let dataArray = data["response"]["body"]["items"]["item"].arrayValue
            completed(dataArray)
        }
    }
    

    func make2amAPIParameter(lat:String, lon:String) -> [String:String] {
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

        if let lat = Double(lat), let lon = Double(lon) {
            nx = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["nx"]!))"
            ny = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["ny"]!))"
        }

        let appid = DataShare.appKey
        let parameter = ["ServiceKey":appid.removingPercentEncoding!,
                         "base_date":date,
                         "base_time":time,
                         "nx":nx,
                         "ny":ny,
                         "_type":"json",
                         "numOfRows":"999"]
        UserDefaults.standard.set(parameter, forKey: DataShare.parameter2am)
        return parameter
    }

    func makeCurruntAPIParameter(lat:String, lon:String) -> [String: String] {
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

        if let lat = Double(lat), let lon = Double(lon) {
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

        let appid = DataShare.appKey
        let parameter = ["ServiceKey": appid.removingPercentEncoding!,
                         "base_date": date,
                         "base_time": time,
                         "nx": nx,
                         "ny": ny,
                         "_type": "json"]
        
        UserDefaults.standard.setValue(parameter, forKey: DataShare.parameterCurrunt)
        print("현재 날씨 파라메터!!: ", parameter)
        return parameter
    }

    func makeForecastAPIParameter(lat:String, lon:String) -> [String:String] {
        
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

        //0200, 0500, 0800, 1100, 1400, 1700, 2000, 2300 제공
        //각 시간 10분 이후부터 API 제공
        guard let setTime = Int(time) else { return ["":""] }
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
        
        if let lat = Double(lat), let lon = Double(lon) {
            nx = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["nx"]!))"
            ny = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["ny"]!))"
        }
        
        let appid = DataShare.appKey
        let parameter = ["ServiceKey":appid.removingPercentEncoding!,
                         "base_date":date,
                         "base_time":time,
                         "nx":nx,
                         "ny":ny,
                         "_type":"json",
                         "numOfRows":"999"]
        print("예보 파라미터들:",date,time,nx,ny)
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
    private func convertGrid(code:String, v1:Double, v2:Double) -> [String:Double] {
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

