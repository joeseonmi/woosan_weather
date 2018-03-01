////
////  WeatherAPIController.swift
////  Woosan
////
////  Created by joe on 2018. 2. 24..
////  Copyright © 2018년 joe. All rights reserved.
////
//
//import UIKit
//import Alamofire
//import SwiftyJSON
//
//class WeatherAPIController {
//    
//   
//    let shared = WeatherAPIController()
//    
//    private let appid = DataShare.appKey
//  
//    let now = Date()
//    let dateFommater = DateFormatter()
//    let timeFommater = DateFormatter()
//    let minFommater = DateFormatter()
//    
//    //낮인지 밤인지 구하는 함수
//    
//    //X,Y 좌표 구하기
//    private func getXY (lat:String,lon:String) -> (nx:String, ny:String) {
//        guard let lat = Double(lat), let lon = Double(lon) else { return ("61","130")}
//        let nx = "\(Int(self.convertGrid(code: "toXY", v1: lat, v2: lon)["nx"]!))"
//        let ny = "\(Int(self.convertGrid(code: "toXY", v1: lat, v2: lon)["ny"]!))"
//        return (nx, ny)
//    }
//    
//    //초단기 실황
//    private func getForecast(lat: String, lon: String,
//                             completed: @escaping (_ crruntInfo:WeatherModel)->Void) {
//    
//        let yesterday = now.addingTimeInterval(-24 * 60 * 60)
//        
//        dateFommater.dateFormat = "yyyyMMdd"
//        timeFommater.dateFormat = "HH"
//        minFommater.dateFormat = "mm"
//        
//        dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
//        
//        var date:String = dateFommater.string(from: now)
//        var time:String = timeFommater.string(from: now)
//        let min:String = minFommater.string(from: now)
//        let setYesterday = dateFommater.string(from: yesterday)
//        
//        //TODO: 12시에 실행해보기
//        if Int(min)! < 30 {
//            let setTime = Int(time)! - 1
//            if setTime < 0 {
//                date = setYesterday
//                time = "23"
//            } else if setTime < 10 {
//                time = "0"+"\(setTime)"
//            } else {
//                time = "\(setTime)"
//            }
//        }
//        time = time + "00"
//        
//        let nx = self.getXY(lat: lat, lon: lon).nx
//        let ny = self.getXY(lat: lat, lon: lon).ny
//        
//        let url = DataShare.forecastChoDangi
//        let parameter = ["ServiceKey":appid.removingPercentEncoding!,
//                         "base_date":date,
//                         "base_time":time,
//                         "nx":nx,
//                         "ny":ny,
//                         "_type":"json"]
//        
//        print("파라미터들(초단기실황):",date,time,nx,ny)
//        
//        Alamofire.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: nil)
//            .responseJSON { (response) in
//            guard let weatherData = response.result.value else { return }
//            let data = JSON(weatherData)
//            
//        }
//        
//    }
//    
//    func getForecastSpaceData(lat: String, lon: String, completed:[]) {
//        var nx = self.getXY(lat: lat, lon: lon).nx
//        var ny = self.getXY(lat: lat, lon: lon).ny
//        let yesterday = now.addingTimeInterval(-24 * 60 * 60)
//        let tomorrow = now.addingTimeInterval(24 * 60 * 60)
//        let dayaftertomorrow = now.addingTimeInterval(48 * 60 * 60)
//        
//        dateFommater.dateFormat = "yyyyMMdd"
//        timeFommater.dateFormat = "HH"
//        minFommater.dateFormat = "mm"
//        //한국시간으로 맞춰주기
//        dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
//        
//        let setYesterday:String = dateFommater.string(from: yesterday)
//        let setTomorrow:String = dateFommater.string(from: tomorrow)
//        let setDayaftertomorrow:String = dateFommater.string(from: dayaftertomorrow)
//        var date:String = dateFommater.string(from: now)
//        let realDate:String = dateFommater.string(from: now)
//        var time:String = timeFommater.string(from: now)
//        let min:String = minFommater.string(from: now)
//        
//        print("오늘:", date,
//              "어제:", setYesterday,
//              "내일:", setTomorrow,
//              "모레:", setDayaftertomorrow)
//        
//        //0200, 0500, 0800, 1100, 1400, 1700, 2000, 2300 제공
//        //각 시간 10분 이후부터 API 제공
//        guard let setTime = Int(time) else { return }
//        if setTime < 2 {
//            date = setYesterday
//            time = "2300"
//        } else if setTime < 5 {
//            time = "0200"
//        } else if setTime < 8 {
//            time = "0500"
//        } else if setTime < 11 {
//            time = "0800"
//        } else if setTime < 14 {
//            time = "1100"
//        } else if setTime < 17 {
//            time = "1400"
//        } else if setTime < 20 {
//            time = "1700"
//        } else if setTime < 23 {
//            time = "2000"
//        } else if setTime >= 23 {
//            time = "2300"
//        }
//        
//        if let lat = Double(lat), let lon = Double(lon) {
//            nx = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["nx"]!))"
//            ny = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["ny"]!))"
//        }
//        let url = DataShare.forecastSpace
//        let parameter = ["ServiceKey":appid.removingPercentEncoding!,
//                         "base_date":date,
//                         "base_time":time,
//                         "nx":nx,
//                         "ny":ny,
//                         "_type":"json",
//                         "numOfRows":"999"]
//        
//        print("파라미터들:",date,time,nx,ny)
//        
//        var yesterDict:[String:String] = [:]
//        var todayDict:[String:String] = [:]
//        var tomorrowDict:[String:String] = [:]
//        var afterDict:[String:String] = [:]
//        
//        
//        Alamofire.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
//            guard let weatherData = response.result.value else { return }
//            let data = JSON(weatherData)
//            let dataArray = data["response"]["body"]["items"]["item"].arrayValue
//            
//            
//            let yesterFroecastArray = dataArray.filter({ (dic) -> Bool in
//                let yesterday:String = dic["fcstDate"].stringValue
//                return yesterday == setYesterday
//            })
//            for i in yesterFroecastArray {
//                var fcsttime:String = i["fcstTime"].stringValue
//                fcsttime = i["fcstTime"].stringValue
//                yesterDict["\(i["category"].stringValue)"] = "\(i["fcstValue"].stringValue)"
//                yesterDict["fcstTime"] = fcsttime
//                yesterDict["fcstDate"] = i["fcstDate"].stringValue
//                self.yesterParseData[fcsttime] = yesterDict
//            }
//            print("어제 정보: ",self.yesterParseData)
//            
//            //오늘 날짜인 예보들을 불러옵니다.
//            let todayForecastArray = dataArray.filter({ (dic) -> Bool in
//                let today:String = dic["fcstDate"].stringValue
//                return today == realDate
//            })
//            //            print("오늘예보만 보여주세요: ",todayForecastArray)
//            for i in todayForecastArray {
//                var fcsttime:String = i["fcstTime"].stringValue
//                fcsttime = i["fcstTime"].stringValue
//                todayDict["\(i["category"].stringValue)"] = "\(i["fcstValue"].stringValue)"
//                todayDict["fcstTime"] = fcsttime
//                todayDict["fcstDate"] = i["fcstDate"].stringValue
//                self.todayParseData[fcsttime] = todayDict
//            }
//            print("오늘 예보: ",self.todayParseData)
//            
//            
//            //내일 날짜인 예보들을 불러옵니다.
//            let tomorrowForecastArray = dataArray.filter({ (dic) -> Bool in
//                let tomorrow:String = dic["fcstDate"].stringValue
//                return tomorrow == setTomorrow
//            })
//            
//            for i in tomorrowForecastArray {
//                var fcsttime:String = i["fcstTime"].stringValue
//                fcsttime = i["fcstTime"].stringValue
//                tomorrowDict["\(i["category"].stringValue)"] = "\(i["fcstValue"].stringValue)"
//                tomorrowDict["fcstTime"] = fcsttime
//                tomorrowDict["fcstDate"] = i["fcstDate"].stringValue
//                self.tommorowParseData[fcsttime] = tomorrowDict
//            }
//            print("내일 예보:", self.tommorowParseData)
//            
//            //모레 날짜인 예보들을 불러옵니다.
//            let afterForecastArray = dataArray.filter({ (dic) -> Bool in
//                let after:String = dic["fcstDate"].stringValue
//                return after == setDayaftertomorrow
//            })
//            
//            for i in afterForecastArray {
//                var fcsttime:String = i["fcstTime"].stringValue
//                fcsttime = i["fcstTime"].stringValue
//                afterDict["\(i["category"].stringValue)"] = "\(i["fcstValue"].stringValue)"
//                afterDict["fcstTime"] = fcsttime
//                afterDict["fcstDate"] = i["fcstDate"].stringValue
//                self.afterParseData[fcsttime] = afterDict
//            }
//            print("모레 예보:", self.afterParseData)
//        }
//    }
//    
//    
//    func get2amData(lat: String, lon: String) {
//        let now = Date()
//        let dateFommater = DateFormatter()
//        let timeFommater = DateFormatter()
//        let minFommater = DateFormatter()
//        var nx = ""
//        var ny = ""
//        let yesterday = now.addingTimeInterval(-24 * 60 * 60)
//        let tomorrow = now.addingTimeInterval(24 * 60 * 60)
//        
//        dateFommater.dateFormat = "yyyyMMdd"
//        timeFommater.dateFormat = "HH"
//        minFommater.dateFormat = "mm"
//        //한국시간으로 맞춰주기
//        dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
//        
//        let setYesterday:String = dateFommater.string(from: yesterday)
//        let setTomorrow:String = dateFommater.string(from: tomorrow)
//        var date:String = dateFommater.string(from: now)
//        var time:String = timeFommater.string(from: now)
//        var realToday:String = dateFommater.string(from: now)
//        
//        guard let setTime = Int(time) else { return }
//        if setTime < 2 {
//            date = setYesterday
//            time = "2300"
//        } else {
//            time = "0200"
//        }
//        
//        if let lat = Double(lat), let lon = Double(lon) {
//            nx = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["nx"]!))"
//            ny = "\(Int(convertGrid(code: "toXY", v1: lat, v2: lon)["ny"]!))"
//        }
//        
//        let appid = DataShare.appKey
//        let url = DataShare.forecastSpace
//        let parameter = ["ServiceKey":appid.removingPercentEncoding!,
//                         "base_date":date,
//                         "base_time":time,
//                         "nx":nx,
//                         "ny":ny,
//                         "_type":"json",
//                         "numOfRows":"999"]
//        
//        print("파라미터들(두시데이터):",date,time,nx,ny)
//        
//        Alamofire.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
//            guard let weatherData = response.result.value else { return }
//            let data = JSON(weatherData)
//            print("ㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇ:", data)
//            let dataArray = data["response"]["body"]["items"]["item"].arrayValue
//            if dataArray.count == 0 {
//                self.todayWeather[Constants.today_key_Max] = "-"
//                self.todayWeather[Constants.today_key_Min] = "-"
//                self.errorAlert(subTitle: "최고/최저 온도 로드 실패😱", subMessage: "서버에서 정보를 불러오지 못했어요.\n나중에 다시 시도해주세요!")
//            } else {
//                for i in 0...dataArray.count - 1 {
//                    if setTime < 2 && dataArray[i]["fcstDate"].stringValue == realToday {
//                        switch dataArray[i]["category"].stringValue {
//                        case Constants.api_max:
//                            let value = dataArray[i]["fcstValue"].stringValue
//                            self.todayWeather[Constants.today_key_Max] = self.roundedTemperature(from: value)
//                        case Constants.api_min:
//                            let value = dataArray[i]["fcstValue"].stringValue
//                            self.todayWeather[Constants.today_key_Min] = self.roundedTemperature(from: value)
//                        default:
//                            print("필요없는 값")
//                        }
//                        
//                    } else if dataArray[i]["fcstDate"].stringValue == date {
//                        switch dataArray[i]["category"].stringValue {
//                        case Constants.api_max:
//                            let value = dataArray[i]["fcstValue"].stringValue
//                            self.todayWeather[Constants.today_key_Max] = self.roundedTemperature(from: value)
//                        case Constants.api_min:
//                            let value = dataArray[i]["fcstValue"].stringValue
//                            self.todayWeather[Constants.today_key_Min] = self.roundedTemperature(from: value)
//                        default:
//                            print("필요없는 값")
//                        }
//                    }
//                }
//            }
//        }
//        
//    }
//    
//    
//    
//    private func roundedTemperature(from temperature:String) -> String {
//        var result:String = ""
//        if let doubleTemperature:Double = Double(temperature) {
//            let intTemperature:Int = Int(doubleTemperature.rounded())
//            result = "\(intTemperature)"
//        }
//        return result
//    }
//    
//    private func convertGrid(code:String, v1:Double, v2:Double) -> [String:Double] {
//        // LCC DFS 좌표변환을 위한 기초 자료
//        let RE = 6371.00877 // 지구 반경(km)
//        let GRID = 5.0 // 격자 간격(km)
//        let SLAT1 = 30.0 // 투영 위도1(degree)
//        let SLAT2 = 60.0 // 투영 위도2(degree)
//        let OLON = 126.0 // 기준점 경도(degree)
//        let OLAT = 38.0 // 기준점 위도(degree)
//        let XO = 43 // 기준점 X좌표(GRID)
//        let YO = 136 // 기1준점 Y좌표(GRID)
//        //
//        //
//        // LCC DFS 좌표변환 ( code : "toXY"(위경도->좌표, v1:위도, v2:경도), "toLL"(좌표->위경도,v1:x, v2:y) )
//        //
//        let DEGRAD = Double.pi / 180.0
//        let RADDEG = 180.0 / Double.pi
//        
//        let re = RE / GRID
//        let slat1 = SLAT1 * DEGRAD
//        let slat2 = SLAT2 * DEGRAD
//        let olon = OLON * DEGRAD
//        let olat = OLAT * DEGRAD
//        
//        var sn = tan(Double.pi * 0.25 + slat2 * 0.5) / tan(Double.pi * 0.25 + slat1 * 0.5)
//        sn = log(cos(slat1) / cos(slat2)) / log(sn)
//        var sf = tan(Double.pi * 0.25 + slat1 * 0.5)
//        sf = pow(sf, sn) * cos(slat1) / sn
//        var ro = tan(Double.pi * 0.25 + olat * 0.5)
//        ro = re * sf / pow(ro, sn)
//        var rs:[String:Double] = [:]
//        var theta = v2 * DEGRAD - olon
//        if (code == "toXY") {
//            
//            rs["lat"] = v1
//            rs["lng"] = v2
//            var ra = tan(Double.pi * 0.25 + (v1) * DEGRAD * 0.5)
//            ra = re * sf / pow(ra, sn)
//            if (theta > Double.pi) {
//                theta -= 2.0 * Double.pi
//            }
//            if (theta < -Double.pi) {
//                theta += 2.0 * Double.pi
//            }
//            theta *= sn
//            rs["nx"] = floor(ra * sin(theta) + Double(XO) + 0.5)
//            rs["ny"] = floor(ro - ra * cos(theta) + Double(YO) + 0.5)
//        }
//        else {
//            rs["nx"] = v1
//            rs["ny"] = v2
//            let xn = v1 - Double(XO)
//            let yn = ro - v2 + Double(YO)
//            let ra = sqrt(xn * xn + yn * yn)
//            if (sn < 0.0) {
//                sn - ra
//            }
//            var alat = pow((re * sf / ra), (1.0 / sn))
//            alat = 2.0 * atan(alat) - Double.pi * 0.5
//            
//            if (abs(xn) <= 0.0) {
//                theta = 0.0
//            }
//            else {
//                if (abs(yn) <= 0.0) {
//                    let theta = Double.pi * 0.5
//                    if (xn < 0.0){
//                        xn - theta
//                    }
//                }
//                else{
//                    theta = atan2(xn, yn)
//                }
//            }
//            let alon = theta / sn + olon
//            rs["lat"] = alat * RADDEG
//            rs["lng"] = alon * RADDEG
//        }
//        return rs
//    }
//
//
//}

