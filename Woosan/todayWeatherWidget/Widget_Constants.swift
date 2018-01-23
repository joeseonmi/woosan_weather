//
//  Widget_Constants.swift
//  todayWeatherWidget
//
//  Created by joe on 2017. 12. 12..
//  Copyright © 2017년 joe. All rights reserved.
//

import Foundation

struct Constants {
    
    static let widgetThemeDataKey = "Theme"
    static let widgetShareDataKey = "group.devjoe.TodayExtensionSharingDefaults"
    
    static let appKey = "Nz1AZqAjQYidfKtkqDExWFKmAbO%2Bn3kcfRZd7Ut%2FzMpTaTH67raoJo599zfgUTDip9IGUXa%2FZpnkCCn7p%2BXd5w%3D%3D"
    static let forecastChoDangi = "http://newsky2.kma.go.kr/service/SecndSrtpdFrcstInfoService2/ForecastGrib"
    static let forecastSpace = "http://newsky2.kma.go.kr/service/SecndSrtpdFrcstInfoService2/ForecastSpaceData"
    
    static let api_hourRain:String = "RN1"
    static let api_rain:String = "POP"
    static let api_rainform:String = "PTY"
    static let api_humi:String = "REH"
    static let api_sky:String = "SKY"
    static let api_min:String = "TMN"
    static let api_max:String = "TMX"
    static let api_wind:String = "WSD"
    static let api_presentTemp:String = "T1H"
    
    //- widget
    static let widget_key_Present = "widget_key_Present"
    static let widget_key_Max = "widget_key_Max"
    static let widget_key_Min = "widget_key_Min"
    static let widget_key_Rain = "widget_key_Rain"
    static let widget_key_RainForm = "widget_key_RainForm"
    static let widget_key_RainCode = "widget_key_RainCode"
    static let widget_key_Dust = "widget_key_Dust"
    static let widget_key_location = "widget_key_location"
    static let widget_key_comment = "widget_key_comment"
    static let widget_key_sky = "widget_key_sky"
    static let widget_key_skyCode = "widget_key_skyCode"
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
            return ("SKY_M01","맑아요!")
        case .LittleCloudy:
            return ("SKY_M02","구름 조금!")
        case .MoreCloudy:
            return ("SKY_M03","구름 많음!")
        case .Cloudy:
            return ("SKY_M04","흐림!")
        case .ClearNight:
            return ("SKY_M08","맑아요!")
        case .LittleCloudyNight:
            return ("SKY_M09","구름 조금!")
        case .Rainy:
            return ("RAIN_M01","비와요!")
        case .Sleet:
            return ("RAIN_M02","진눈깨비!")
        case .Snow:
            return ("RAIN_M03","눈와요!")
        }
    }
}

