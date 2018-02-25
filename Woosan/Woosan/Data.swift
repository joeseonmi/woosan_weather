//
//  theme.swift
//  Woosan
//
//  Created by joe on 2018. 1. 21..
//  Copyright © 2018년 joe. All rights reserved.
//

import Foundation

struct DataShare {
    //Userdefult Key
    static let selectedThemeKey = "Them"
    
    static let widgetShareDataKey = "group.devjoe.TodayExtensionSharingDefaults"
    static let widgetThemeDataKey = "Theme"
    
    static let appKey = ""
    static let forecastChoDangi = "http://newsky2.kma.go.kr/service/SecndSrtpdFrcstInfoService2/ForecastGrib"
    static let forecastSpace = "http://newsky2.kma.go.kr/service/SecndSrtpdFrcstInfoService2/ForecastSpaceData"
    static let dustApi = "http://openapi.airkorea.or.kr/openapi/services/rest/ArpltnInforInqireSvc/getCtprvnMesureLIst"
    
    
}

struct ThemeInfo {
    static let titles:[String] = ["우산 챙기개!(기본)",
                                  "우산 챙겼냥!"]
    
    static let subscrip:[String] = ["우산챙기개! 기본테마. 강아지가 뛰어댕겨요.",
                                    "얼룩이 고양이가 뛰어댕겨요."]
    
    static let image:[String] = ["doggythemIcon",
                                 "dungsilcatthemIcon"]
}

enum Theme: Int {
    case doggy = 0
    case catty
    
    func convertName() -> String {
        switch self {
        case .doggy:
            return "doggy"
        case .catty:
            return "catty"
        }
    }
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

