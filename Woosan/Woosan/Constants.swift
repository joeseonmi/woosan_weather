//
//  Constants.swift
//  Woosan
//
//  Created by joe on 2017. 11. 29..
//  Copyright © 2017년 joe. All rights reserved.
//

import Foundation


struct Constants {
    
    //- for API
    static let api_hourRain:String = "RN1"
    static let api_rain:String = "POP"
    static let api_rainform:String = "PTY"
    static let api_humi:String = "REH"
    static let api_sky:String = "SKY"
    static let api_min:String = "TMN"
    static let api_max:String = "TMX"
    static let api_wind:String = "WSD"
    static let api_presentTemp:String = "T1H"
    
    //- otherInfo
    static let otherInfo_key_time:String = "otherInfo_key_time"
    static let otherInfo_key_location:String = "otherInfo_key_location"
    static let otherInfo_nullData:String = "데이터가 없습니다."
 
    //- today
    static let today_key_Present = "today_key_Present"
    static let today_key_Max:String = "today_key_Max"
    static let today_key_Min:String = "today_key_Min"
    static let today_key_Sky:String = "today_key_Sky"
    static let today_key_Rain:String = "today_key_Rain"
    static let today_key_Rainform:String = "today_key_RainForm"
    static let today_key_RainCode:String = "today_key_RainCode"
    static let today_key_SkyCode:String = "today_key_Code"
    static let today_key_Wind = "today_key_Wind"
    static let today_key_Humi = "today_key_Humi"
    static let today_key_Dust = "today_key_Dust"
    
    //- yesterday
    static let yesterday_key_Max:String = "yesterday_key_Max"
    static let yesterday_key_Min:String = "yesterday_key_Min"
    static let yesterday_key_Sky:String = "yesterday_key_Sky"
    static let yesterday_key_Rainform:String = "yesterday_key_RainForm"
  
    //- tomorrow
    static let tomorrow_key_Max:String = "tomorrow_key_Max"
    static let tomorrow_key_Min:String = "tomorrow_key_Min"
    static let tomorrow_key_Sky:String = "tomorrow_key_Sky"
    static let tomorrow_key_Rainform:String = "tomorrow_key_RainForm"
    
    //- aftertomorrow
    static let aftertomorrow_key_Max:String = "aftertomorrow_key_Max"
    static let aftertomorrow_key_Min:String = "aftertomorrow_key_Min"
    static let aftertomorrow_key_Sky:String = "aftertomorrow_key_Sky"
    static let aftertomorrow_key_Rainform:String = "aftertomorrow_key_RainForm"
    
}

extension String {
    func URLEncodedString() -> String? {
        let customAllowedSet =  NSCharacterSet.urlQueryAllowed
        let escapedString = self.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
        return escapedString
    }
}
