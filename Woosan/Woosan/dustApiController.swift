//
//  dustApiController.swift
//  Woosan
//
//  Created by joe on 2018. 2. 21..
//  Copyright © 2018년 joe. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class dustAPIController {
    
    static let shared = dustAPIController()
    
    func todayDustInfo(_ cityName:String, dustData: @escaping (_ data:todayDust) -> Void) {
        requestDust(cityName: cityName) { (response) in
            //여기서 데이터 구성
            var totalDustData = [todayDust]()
            for data in response.arrayValue {
                let responsecityName = data["stationName"].stringValue
                let pm10 = data["pm10Value"].stringValue
                let pm25 = data["pm25Value"].stringValue
                let time = data["dataTime"].stringValue
                let comment = self.convertComment(dustScore: pm10)
                let tempTodatDust = todayDust(time: time,
                                              location: responsecityName,
                                              dust10Value: pm10,
                                              dust25Value: pm25,
                                              dustComment: comment)
                totalDustData.append(tempTodatDust)
            }
            var pm10Average:String = ""
            var sumPM10:Int = 0
            for data in totalDustData {
                if let pm10 = Int(data.dust10Value) {
                    sumPM10 += pm10
                } else {
                    sumPM10 += 0
                }
            }
            pm10Average = "\(sumPM10 / totalDustData.count)"
            
            var pm25Average:String = ""
            var sumPM25:Int = 0
            var emptycount = 0
            for data in totalDustData {
                if let pm25 = Int(data.dust25Value) {
                    sumPM25 += pm25
                } else {
                    sumPM25 += 0
                    emptycount += 1
                }
            }
            pm25Average = "\(sumPM25 / (totalDustData.count - emptycount))"

            let now = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd-HH"
            let time = formatter.string(from: now)
            var curruntDustData:todayDust = todayDust(time: time,
                                                      location: "정보 없음",
                                                      dust10Value: "0",
                                                      dust25Value: "0",
                                                      dustComment: "정보 없음")
            curruntDustData.location = cityName
            curruntDustData.dust10Value = pm10Average
            curruntDustData.dust25Value = pm25Average
            curruntDustData.dustComment = self.convertComment(dustScore: pm10Average)
            curruntDustData.time = time
            dustData(curruntDustData)
           
//            guard let shareData = UserDefaults(suiteName: DataShare.widgetShareDataKey) else { return }
//            shareData.set(curruntDustData, forKey: DataShare.dustDataKey)
//            shareData.synchronize()
        }
    }
    
    private func convertComment(dustScore:String) -> String {
        guard let score = Int(dustScore) else { return "정보 없음" }
        if 0 < score && score <= 30 {
            return "좋음"
        } else if 30 < score && score <= 80 {
            return "보통"
        } else if 80 < score && score <= 150 {
            return "나쁨"
        } else if score > 150 {
            return "매우 나쁨"
        }
        return "정보 없음"
    }
    
    private func convertName(eng: String) -> String {
        switch eng {
        case "Seoul","서울특별시": return "서울"
        case "Busan","부산광역시": return "부산"
        case "Daegu","대구광역시": return "대구"
        case "Incheon","인천광역시": return "인천"
        case "Gwangju", "광주광역시": return "광주"
        case "Daejeon", "대전광역시": return "대전"
        case "Gyeonggi-do", "경기도": return "경기"
        case "Gangwon","강원도": return "강원"
        case "North Chungcheong","충청북도": return "충북"
        case "South Chungcheong","충청남도": return "충남"
        case "North Jeolla","전라북도": return "전북"
        case "South Jeolla","전라남도": return "전남"
        case "North Gyeongsang","경상북도": return "경북"
        case "South Gyeongsang","경상남도": return "경남"
        case "Jeju","제주도","제주시": return "제주"
        default: return "위치 확인 불가"
        }
    }
    
    private func requestDust(cityName:String, completion: @escaping (_ dustValue:JSON) -> Void) {
        let sidoName:String = self.convertName(eng: cityName)
        let appkey = DataShare.appKey
        let url = DataShare.dustApi
        let parameter = ["ServiceKey":appkey.removingPercentEncoding!,
                         "ver":"1.3",
//                         "pageNo":"1",
//                         "numOfRows":"10",
                         "sidoName":sidoName,
                         "_returnType":"json"]
        
    Alamofire.request(url, method: .get,
                      parameters: parameter,
                      encoding: URLEncoding.default,
                      headers: nil)
        .responseJSON { (response) in
            guard let responseData = response.result.value else { return }
            let tempData = JSON(responseData)
            let today = tempData["list"]
            completion(today)
        }
    }
    
}

struct todayDust {
    
    var time:String
    var location:String
    var dust10Value:String
    var dust25Value:String
    var dustComment:String
  
}


