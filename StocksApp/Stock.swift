//
//  Stock.swift
//  StocksApp
//
//  Created by Hunter Kingsbeer on 21/07/21.
//

import Foundation
import SwiftyJSON
import Alamofire
import CoreData

extension Stock {
    static func fetchAllStockData() {
        let stocks = getStocks()
        
        DispatchQueue.main.async {
            for stock in stocks {
                AF.request(getFetchURL(symbol: stock.symbol ?? "", demo: true), method: .get).validate().responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        if let usPrice = json["c"].double {
                            if usPrice != 0 {
                                stock.price = usPrice
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
        save()
    }
    
    static func fetchStockData(symbol: String) {
        DispatchQueue.main.async {
            AF.request(getFetchURL(symbol: symbol, demo: true), method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if let usPrice = json["c"].double {
                        getStock(symbol: symbol).price = usPrice
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        save()
    }
    
    static func getFetchURL(symbol: String, demo: Bool) -> String {
        let usKey = "c0guqcn48v6ttm1squcg"
        let demoKey = "sandbox_c0guqcn48v6ttm1squd0"
        
        return demo ? "https://finnhub.io/api/v1/quote?symbol=\(symbol)&token=\(demoKey)" : "https://finnhub.io/api/v1/quote?symbol=\(symbol)&token=\(usKey)"
    }
    
    
    static func addStock(title: String, symbol: String, input: Double, shares: Double, category: String) {
        let viewContext = PersistenceController.shared.getContext()
        
        let newStock = Stock(context: viewContext)
        newStock.id = UUID()
        newStock.title = title.capitalized
        newStock.symbol = symbol
        newStock.input = input
        newStock.shares = shares
        newStock.category = category
        save()
        fetchStockData(symbol: symbol)
        print("New stock: \(title)")
    }
    
    static func getStock(symbol: String) -> Stock {
        for stock in getStocks() {
            if stock.symbol?.lowercased() == symbol.lowercased(){
                return stock
            }
        }
        return Stock()
    }
    
    /// Returns an array of all stocks.
    static func getStocks() -> [Stock] {
        let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Stock.title, ascending: true)]
        do {
            let managedObjectContext = PersistenceController.shared.getContext()
            let stocks = try managedObjectContext.fetch(fetchRequest)
            return stocks
          } catch let error as NSError {
            print("Error fetching Stocks: \(error.localizedDescription), \(error.userInfo)")
          }
        return [Stock]()
    }
    
    /// Deletes a stock
    static func delete(stock: Stock) {
        let viewContext = PersistenceController.shared.getContext()
        print("Deleted stock: \(String(describing: stock.title))")
        viewContext.delete(stock)
        save()
    }
    
    /// Saves the context
    static func save() {
        let viewContext = PersistenceController.shared.getContext()
        do {
            try  viewContext.save()
        } catch {
            // TODO: Replace this implementation with code to handle the error appropriately.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    /// returns the color relating to the stocks "action" button
    static func color(stockMode: StockMode, pendingDelete: Bool) -> String {
        return stockMode == .editing ? "yellow" : stockMode == .deleting ? pendingDelete ? "red" : "accent" : "accent"
    }
}
