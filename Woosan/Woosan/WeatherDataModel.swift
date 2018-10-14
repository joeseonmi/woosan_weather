//
//  WeatherDataModel.swift
//  Woosan
//
//  Created by joe on 2018. 10. 14..
//  Copyright © 2018년 joe. All rights reserved.
//

import Foundation

struct WeatherItem: Decodable {
    let baseDate: Int
    let baseTime: Int
    let category: String
    let nx: Int
    let ny: Int
    let obsrValue: Double
}

struct WeatherResponse: Decodable {
    let response: CurruntResponse
}

struct CurruntResponse: Decodable {
    let header: CurruntHeader
    let body: CurruntBody
}

struct CurruntHeader: Decodable {
    let resultCode: String
    let resultMsg: String
}

struct CurruntBody: Decodable {
    let items: WeatherItems
    let numOfRows: Int
    let pageNo: Int
    let totalCount: Int
}

struct WeatherItems: Decodable {
    let item: [WeatherItem]
    
    private func convertWind(wind: Int) -> String {
        if wind < 4 {
            return "약해요"
        } else if wind >= 4 && wind < 9 {
            return "약간 강해요"
        } else if wind >= 9 && wind < 14 {
            return "강해요"
        } else {
            return "매우 강해요"
        }
    }
    
    func convertCurrunt() -> CurruntWeather {
        var currunt = CurruntWeather(curruntTemp: "", rain: "", wind: "", humi: "", sky: "", icon: "")
        
        let humi = item.filter { source -> Bool in
            return source.category == Constants.api_humi
            }.first?.obsrValue.rounded()
        if let humi = humi {
            currunt.humi = "\(Int(humi))%"
        }
        
        let temp = item.filter { source -> Bool in
            return source.category == Constants.api_presentTemp
            }.first?.obsrValue.rounded()
        if let temp = temp {
            currunt.curruntTemp = "\(Int(temp.rounded()))"
        }
        
        let rain = item.filter { source -> Bool in
            return source.category == Constants.api_hourRain
            }.first?.obsrValue
        if let rain = rain {
            currunt.rain = "강수량: \(Int(rain.rounded()))mm"
        }
        
        let wind = item.filter { source -> Bool in
            return source.category == Constants.api_wind
            }.first?.obsrValue
        if let wind = wind {
            currunt.wind = convertWind(wind: Int(wind))
        }
        
        let rainform = item.filter { source -> Bool in
            return source.category == Constants.api_rainform
            }.first?.obsrValue
        
        let now = Date()
        let dateFommater = DateFormatter()
        let timeFommater = DateFormatter()
        
        timeFommater.dateFormat = "HH"
        //한국시간으로 맞춰주기
        dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
        
        let time = timeFommater.string(from: now)
        var dayOrNight = 00
        
        if let tempTime = Int(time) {
            dayOrNight = tempTime
        }
        
        if let rainform = rainform {
            let code = Int(rainform)
            switch code {
            case 0:
                if dayOrNight > 6 && dayOrNight < 20 {
                    currunt.sky = Weather.Sunny.convertName().subs
                    currunt.icon = Weather.Sunny.convertName().code
                } else {
                    currunt.sky = Weather.ClearNight.convertName().subs
                    currunt.icon = Weather.ClearNight.convertName().code
                }
            case 1:
                currunt.sky = Weather.Rainy.convertName().subs
                currunt.icon = Weather.Rainy.convertName().code
            case 2:
                currunt.sky = Weather.Sleet.convertName().subs
                currunt.icon = Weather.Sleet.convertName().code
            case 3:
                currunt.sky = Weather.Snow.convertName().subs
                currunt.icon = Weather.Snow.convertName().code
            default:
                if dayOrNight > 6 && dayOrNight < 20 {
                    currunt.sky = Weather.Sunny.convertName().subs
                    currunt.icon = Weather.Sunny.convertName().code
                } else {
                    currunt.sky = Weather.ClearNight.convertName().subs
                    currunt.icon = Weather.ClearNight.convertName().code
                }
            }
        }
            return currunt
    }
    
    func convertWidgetCurrunt() -> todayWeather {
        
        var currunt = todayWeather(curruntTemp: "", rain: "", weatherIcon: "", comment: "")
        
        
        let temp = item.filter { source -> Bool in
            return source.category == Constants.api_presentTemp
            }.first?.obsrValue.rounded()
        if let temp = temp {
            currunt.curruntTemp = "\(Int(temp.rounded()))"
        }
        
        let humi = item.filter { source -> Bool in
            return source.category == Constants.api_humi
            }.first?.obsrValue
        if let humi = humi {
            currunt.rain = "습도: \(Int(humi))%"
        }
        
        let rainform = item.filter { source -> Bool in
            return source.category == Constants.api_rainform
            }.first?.obsrValue
        
        let now = Date()
        let dateFommater = DateFormatter()
        let timeFommater = DateFormatter()
        
        timeFommater.dateFormat = "HH"
        //한국시간으로 맞춰주기
        dateFommater.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
        
        let time = timeFommater.string(from: now)
        var dayOrNight = 00
        
        if let tempTime = Int(time) {
            dayOrNight = tempTime
        }
        
        if let rainform = rainform {
            let code = Int(rainform)
            switch code {
            case 0:
                if dayOrNight > 6 && dayOrNight < 20 {
                    currunt.comment = Weather.Sunny.convertWidgetName().subs
                    currunt.weatherIcon = Weather.Sunny.convertWidgetName().code
                } else {
                    currunt.comment = Weather.ClearNight.convertWidgetName().subs
                    currunt.weatherIcon = Weather.ClearNight.convertWidgetName().code
                }
            case 1:
                currunt.comment = Weather.Rainy.convertWidgetName().subs
                currunt.weatherIcon = Weather.Rainy.convertWidgetName().code
            case 2:
                currunt.comment = Weather.Sleet.convertWidgetName().subs
                currunt.weatherIcon = Weather.Sleet.convertWidgetName().code
            case 3:
                currunt.comment = Weather.Snow.convertWidgetName().subs
                currunt.weatherIcon = Weather.Snow.convertWidgetName().code
            default:
                if dayOrNight > 6 && dayOrNight < 20 {
                    currunt.comment = Weather.Sunny.convertWidgetName().subs
                    currunt.weatherIcon = Weather.Sunny.convertWidgetName().code
                } else {
                    currunt.comment = Weather.ClearNight.convertWidgetName().subs
                    currunt.weatherIcon = Weather.ClearNight.convertWidgetName().code
                }            }
        }
        return currunt
    }
    
    
}



