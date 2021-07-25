//
//  Keys.swift
//  StocksApp
//
//  Created by Hunter Kingsbeer on 25/07/21.
//

import Foundation

struct Keys {
    static let usKey = "c0guqcn48v6ttm1squcg"
    static let demoKey = "sandbox_c0guqcn48v6ttm1squd0"
    
    static func getUSKey() -> String {
        return usKey
    }
    
    static func getDemoKey() -> String {
        return demoKey
    }
}
