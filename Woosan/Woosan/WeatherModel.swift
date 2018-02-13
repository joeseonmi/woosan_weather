//
//  WeatherModel.swift
//  Woosan
//
//  Created by joe on 2018. 2. 13..
//  Copyright © 2018년 joe. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation

class SKapiController {
    
    struct WeatherModel {
        let curruntTemp:String
        let todayMin:String
        let todayMax:String
        let rain:String
        let wind:String
        let humi:String
        let location:String
        let sky:String
        
        static let empty = WeatherModel(curruntTemp: "00", todayMin: "00", todayMax: "00", rain: "00", wind: "00", humi: "00", location: "정보를 가져올수 없음", sky: "default")
        
    }
    
    static let shared = SKapiController()
    private let appKey = "744a895d-6524-4720-8c9b-535b15791541"
    
}


class KMAapiController {
    
    struct WeatherModel {
        let curruntTemp:String
        let todayMin:String
        let todayMax:String
        let rain:String
        let wind:String
        let humi:String
        let location:String
        let sky:String
        
        static let empty = WeatherModel(curruntTemp: "00", todayMin: "00", todayMax: "00", rain: "00", wind: "00", humi: "00", location: "정보를 가져올수 없음", sky: "default")
        
    }
    
    static let shared = KMAapiController()
    private let appKey = "Nz1AZqAjQYidfKtkqDExWFKmAbO%2Bn3kcfRZd7Ut%2FzMpTaTH67raoJo599zfgUTDip9IGUXa%2FZpnkCCn7p%2BXd5w%3D%3D"
    
//    func curruntWeather(lat:String, lon:String) -> WeatherModel {
//        
//    }
//    
    //반올림하기
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
