//
//  Groups.swift
//  StocksApp
//
//  Created by Hunter Kingsbeer on 4/07/21.
//

import Foundation
import CoreData

class Category {
    var title : String
    var symbol : String
    var icon : String
    var subicons : String
    var tags : String
    var color : String
    var id = UUID()
    
    init(title: String, symbol: String, icon: String, subicons: String, tags: String, color: String) {
        self.title = title
        self.symbol = symbol
        self.icon = icon
        self.subicons = subicons
        self.tags = tags
        self.color = color
    }
    
    static let categories : [Category] = [Category(title: "Materials Production.",
                                                   symbol: "materials",
                                                   icon: "rectangle.grid.1x2",
                                                   subicons: "aqi.medium,smallcircle.circle,rectangle.grid.1x2",
                                                   tags: "metal,steel,silicone,lumbar,iron,copper,cobalt,rare earth minerals,materials,production",
                                                   color: "red"),
                                   
                                          Category(title: "Power & Utilities.",
                                                   symbol: "power",
                                                   icon: "bolt.horizontal.fill",
                                                   subicons: "lightbulb.fill,antenna.radiowaves.left.and.right,bolt.horizontal.fill",
                                                   tags: "energy,power,utilities,internet,phone,services",
                                                   color: "yellow"),
                                   
                                          Category(title: "Retail.",
                                                   symbol: "retail",
                                                   icon: "tag.fill",
                                                   subicons: "bag.fill,cart.fill,tag.fill",
                                                   tags: "shopping,stores,clothing,department",
                                                   color: "pink"),
                                   
                                          Category(title: "Clean & Renewables.",
                                                   symbol: "clean",
                                                   icon: "leaf.fill",
                                                   subicons: "wind,bolt.horizontal.fill,leaf.fill",
                                                   tags: "electric,solar,green energy,solar,hydro",
                                                   color: "green"),
                                   
                                          Category(title: "Technology.",
                                                   symbol: "tech",
                                                   icon: "wifi",
                                                   subicons: "bubble.left.fill,display,wifi",
                                                   tags: "tech,technology,social media,startup,computers,online",
                                                   color: "blue"),
                                          Category(title: "Automotive.",
                                                   symbol: "cars",
                                                   icon: "car.fill",
                                                   subicons: "key.fill,map.fill,car.fill",
                                                   tags: "cars,automotive,electric cars,fuel",
                                                   color: "cyan")]
    
    static func icon(symbol: String) -> String {
        let groupObj : Category = getCategory(symbol: symbol)
        if !groupObj.icon.isEmpty {
            return groupObj.icon
        }
        return "circle.fill"
    }
    
    static func availableCategories() -> [Category]{
        var stockCategories : [String] = []
        var avblCategories : [Category] = []
        for stock in Stock.getStocks() {
            if !stockCategories.contains(stock.category ?? ""){
                stockCategories.append(stock.category?.lowercased() ?? "")
            }
        }
        for category in categories {
            if stockCategories.contains(category.symbol.lowercased()){
                avblCategories.append(category)
            }
        }
        return avblCategories
    }
    
    static func color(symbol: String) -> String {
        let groupObj : Category = getCategory(symbol: symbol)
        if !groupObj.color.isEmpty {
            return groupObj.color
        }
        return "text"
    }
    
    /// Returns the Category matching the title
    static func getCategory(symbol: String) -> Category {
        for group in categories {
            if group.symbol.lowercased() == symbol.lowercased() {
                return group
            }
        }
        return Category(title: "", symbol: "", icon: "", subicons: "", tags: "", color: "")
    }
}
