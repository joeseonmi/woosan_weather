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
    
    func todayDustInfo() {
        self.requestDust { (dustData) in
            print("요기나오면 참 좋게따:", dustData)
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
            guard let data = response.value else { return }
            let dustData = JSON(data)
            completion(dustData)
        }
    }
    
}

struct todayDust {
    
    let location:String
    let grade:String
    let dustComment:String

}

enum locationName {
    
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
    
    func convertLocationName() -> String {
        switch self {
        case .busan:
            return "부산"
        case .chungbuk:
            return "충북"
        case .chungnam:
            return "충남"
        case .daegu:
            return "대구"
        case .daejeon:
            return "대전"
        case .gangwon:
            return "강원"
        case .gwangju:
            return "광주"
        case .gyeongbuk:
            return "경북"
        case .gyeonggi:
            return "경기"
        case .gyeongnam:
            return "경남"
        case .incheon:
            return "인천"
        case .jeju:
            return "제주"
        case .jeonbuk:
            return "전북"
        case .jeonnam:
            return "전남"
        case .sejong:
            return "세종"
        case .seoul:
            return "서울"
        case .ulsan:
            return "울산"
        }
    }
}
