//
//  WeatherModel.swift
//  Woosan
//
//  Created by joe on 2018. 2. 13..
//  Copyright © 2018년 joe. All rights reserved.
//

import Foundation

struct TempMaxMinData {

    let max:String
    let min:String
    
    static let empty = TempMaxMinData(max: "-",
                                      min: "-")
}

struct CurruntWeather {
    
    let curruntTemp:String
    let rain:String
    let wind:String
    let humi:String
    let sky:String
    let icon:String
    
    static let empty = CurruntWeather(curruntTemp: "00",
                                      rain: "-",
                                      wind: "-",
                                      humi: "-",
                                      sky: "정보 없음",
                                      icon: "weather_default")
}

struct ForecastWeather {

    let forecastTime:String
    let forecast:[String:String]
    
    static let empty = ForecastWeather(forecastTime: "-",
                                       forecast: ["category":"value"])
    
}


enum Weather {
    case Sunny
    case LittleCloudy
    case MoreCloudy
    case Cloudy
    case ClearNight
    case LittleCloudyNight
    case Rainy
    case Sleet
    case Snow
    
    func convertName() -> (code:String, subs:String){
        switch self {
        case .Sunny:
            return ("SKY_D01","맑음")
        case .LittleCloudy:
            return ("SKY_D02","구름 조금")
        case .MoreCloudy:
            return ("SKY_D03","구름 많음")
        case .Cloudy:
            return ("SKY_D04","흐림")
        case .ClearNight:
            return ("SKY_D08","맑음")
        case .LittleCloudyNight:
            return ("SKY_D09","구름 조금")
        case .Rainy:
            return ("RAIN_D01","비")
        case .Sleet:
            return ("RAIN_D02","진눈깨비")
        case .Snow:
            return ("RAIN_D03","눈")
        }
    }
}
