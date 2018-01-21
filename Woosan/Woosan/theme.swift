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
    static let widgetShareDataKey = "group.joe.TodayExtensionSharingDefaults"
    
    static let appKey = "Nz1AZqAjQYidfKtkqDExWFKmAbO%2Bn3kcfRZd7Ut%2FzMpTaTH67raoJo599zfgUTDip9IGUXa%2FZpnkCCn7p%2BXd5w%3D%3D"
    static let forecastChoDangi = "http://newsky2.kma.go.kr/service/SecndSrtpdFrcstInfoService2/ForecastGrib"
    static let forecastSpace = "http://newsky2.kma.go.kr/service/SecndSrtpdFrcstInfoService2/ForecastSpaceData"
    
    
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
    case SKY_D01
    case SKY_D02
    case SKY_D03
    case SKY_D04
    case SKY_D08
    case SKY_D09
    case RAIN_D01
    case RAIN_D02
    case RAIN_D03
    
    func convertName() -> String{
        switch self {
        case .SKY_D01:
            return "맑음"
        case .SKY_D02:
            return "구름 조금"
        case .SKY_D03:
            return "구름 많음"
        case .SKY_D04:
            return "흐림"
        case .SKY_D08:
            return "맑음"
        case .SKY_D09:
            return "구름 조금"
        case .RAIN_D01:
            return "비"
        case .RAIN_D02:
            return "진눈깨비"
        case .RAIN_D03:
            return "눈"
        }
    }
}

