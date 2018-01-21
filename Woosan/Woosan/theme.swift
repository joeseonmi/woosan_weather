//
//  theme.swift
//  Woosan
//
//  Created by joe on 2018. 1. 21..
//  Copyright © 2018년 joe. All rights reserved.
//

import Foundation

enum Theme: Int {
    case doggy = 0
    case catty
    
    func switchName() -> String {
        switch self {
        case .doggy:
            return "doggy"
        case .catty:
            return "catty"
        }
    }
}
