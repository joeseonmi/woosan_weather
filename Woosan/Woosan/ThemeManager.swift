//
//  ThemeManager.swift
//  Woosan
//
//  Created by joe on 2018. 3. 8..
//  Copyright © 2018년 joe. All rights reserved.
//

import Foundation

class ThemeManager {
    
    
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
