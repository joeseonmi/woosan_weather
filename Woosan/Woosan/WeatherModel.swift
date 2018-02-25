//
//  WeatherModel.swift
//  Woosan
//
//  Created by joe on 2018. 2. 13..
//  Copyright © 2018년 joe. All rights reserved.
//

import Foundation

struct TemperData {

    let max:String
    let min:String
    
    static let empty = TemperData(max: "-",
                                  min: "-")
}

struct WeatherModel {
    
    let curruntTemp:String
    let rain:String
    let wind:String
    let humi:String
    let location:String
    let sky:String
    
    static let empty = WeatherModel(curruntTemp: "00",
                                    rain: "-",
                                    wind: "-",
                                    humi: "-",
                                    location: "정보 없음",
                                    sky: "정보 없음")
}

struct forecastModel {
    
    let time:String
    let icon:String
    let temp:String
    
    static let empty = forecastModel(time: "00",
                                     icon: "default",
                                     temp: "-")
    
}
