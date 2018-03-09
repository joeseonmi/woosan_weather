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
