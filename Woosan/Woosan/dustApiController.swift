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
    
    func todayDustInfo(_ location:String, dustData: @escaping (_ data:[String:todayDust]) -> Void) {
        requestDust { (response) in
            let tempData = response.dictionaryValue
            var dustDataDict:[String:todayDust] = [:]
            let keys = tempData.keys.sorted()
            for i in keys {
                guard let value = tempData[i] else { return }
                let temp = todayDust(location: self.convertName(eng: i),
                                           dustValue: value.stringValue,
                                           dustComment: self.convertComment(dustScore: value.stringValue))
                if temp.location == "정보 없음"  {
                    print("지역이 아님")
                } else {
                    dustDataDict[i] = temp
                }
            }
            dustData(dustDataDict)
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
        case "busan": return "부산"
        case "chungbuk": return "충북"
        case "chungnam": return "충남"
        case "daegu": return "대구"
        case "daejeon": return "대전"
        case "gangwon": return "강원"
        case "gwangju": return "광주"
        case "gyeongbuk": return "경북"
        case "gyeonggi": return "경기"
        case "gyeongnam": return "경남"
        case "incheon": return "인천"
        case "jeju": return "제주"
        case "jeonbuk": return "전북"
        case "jeonnam": return "전남"
        case "sejong": return "세종"
        case "seoul": return "서울"
        case "ulsan": return "울산"
        default:
            return "정보 없음"
        }
    }
    
    private func requestDust(completion: @escaping (_ dustValue:JSON) -> Void) {
        let appkey = DataShare.appKey
        let url = DataShare.dustApi
        let parameter = ["itemCode":"PM10",
                         "dataGubun":"HOUR",
                         "ServiceKey":appkey.removingPercentEncoding!,
                         "ver":"1.3",
                         "_returnType":"json"]
        
    Alamofire.request(url, method: .get,
                      parameters: parameter,
                      encoding: URLEncoding.default,
                      headers: nil)
        .responseJSON { (response) in
            guard let responseData = response.result.value else { return }
            let tempData = JSON(responseData)
            let today = tempData["list"][0]
            completion(today)
        }
    }
    
}

struct todayDust {
    
    var location:String
    var dustValue:String
    var dustComment:String

}

enum DustlocationName {
    
    case busan
    case chungbuk
    case chungnam
    case daegu
    case daejeon
    case gangwon
    case gwangju
    case gyeongbuk
    case gyeonggi
    case gyeongnam
    case incheon
    case jeju
    case jeonbuk
    case jeonnam
    case sejong
    case seoul
    case ulsan
    
    func convertLocationName() -> (kor: String, eng: String) {
        switch self {
        case .busan: return ("부산","busan")
        case .chungbuk: return ("충북","chungbuk")
        case .chungnam: return ("충남","chungnam")
        case .daegu: return ("대구","daegu")
        case .daejeon: return ("대전","daejeon")
        case .gangwon: return ("강원","gangwon")
        case .gwangju: return ("광주","gwangju")
        case .gyeongbuk: return ("경북","gyeongbuk")
        case .gyeonggi: return ("경기","gyeonggi")
        case .gyeongnam: return ("경남","gyeongnam")
        case .incheon: return ("인천","incheon")
        case .jeju: return ("제주","jeju")
        case .jeonbuk: return ("전북","jeonbuk")
        case .jeonnam: return ("전남","jeonnam")
        case .sejong: return ("세종","sejong")
        case .seoul: return ("서울","seoul")
        case .ulsan: return ("울산","ulsan")
        }
    }
}
