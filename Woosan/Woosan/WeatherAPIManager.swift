//
//  WeatherAPIManager.swift
//  Woosan
//
//  Created by joe on 2018. 10. 14..
//  Copyright © 2018년 joe. All rights reserved.
//

import Foundation
import Moya

enum WeatherAPI {
    case curruntWeater(lat:String, lon:String)
    case maxminTemp(lat:String, lon:String)
    case forecast(lat:String, lon:String)
}

extension WeatherAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://newsky2.kma.go.kr/service/SecndSrtpdFrcstInfoService2")!
    }
    
    var path: String {
        switch self {
        case .curruntWeater:
            return "/ForecastGrib"
        case .maxminTemp:
            return "/ForecastSpaceData"
        case .forecast:
            return "/ForecastSpaceData"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .curruntWeater(let lat, let lon):
            var parameter = [String: String]()
            parameter = ParameterManager.shared.currunt(lat: lat, lon: lon)
            return .requestParameters(parameters: parameter, encoding: URLEncoding.default)
            
        case .maxminTemp(let lat, let lon):
            var parameter = [String: String]()
            parameter = ParameterManager.shared.maxmin(lat: lat, lon: lon)
            return .requestParameters(parameters: parameter, encoding: URLEncoding.default)
            
        case .forecast(let lat, let lon):
            var parameter = [String: String]()
            parameter = ParameterManager.shared.forecast(lat: lat, lon: lon)
            return .requestParameters(parameters: parameter, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? { return nil }

}

struct WeatherAPIAdapter {
    
    static let provider = MoyaProvider<WeatherAPI>()
    
    static func request(target: WeatherAPI,
                        success successCallback: @escaping (Response) -> Void,
                        error errorCallback: @escaping (Response) -> Void,
                        failure failureCallback: @escaping (MoyaError) -> Void) {
        
        provider.request(target) { (result) in
            switch result {
            case .success(let response):
                if response.statusCode >= 200 && response.statusCode < 400 {
                    successCallback(response)
                } else {
                    errorCallback(response)
                }
            case .failure(let error):
                failureCallback(error)
            }
        }
    }
    
}

