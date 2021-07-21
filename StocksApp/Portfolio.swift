//
//  Portfolio.swift
//  StocksApp
//
//  Created by Hunter Kingsbeer on 22/07/21.
//

import Foundation
import CoreData

extension Portfolio {
    static func getPortfolios() -> [Portfolio] {
        let fetchRequest: NSFetchRequest<Portfolio> = Portfolio.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Portfolio.total, ascending: true)]
        do {
            let managedObjectContext = PersistenceController.shared.getContext()
            let portfolios = try managedObjectContext.fetch(fetchRequest)
            return portfolios
          } catch let error as NSError {
            print("Error fetching Folders: \(error.localizedDescription), \(error.userInfo)")
          }
        return [Portfolio()]
    }
    
    static func getPortfolio() -> Portfolio {
        if !doesPortfolioExist(){
            createPortfolio()
        }
        return getPortfolios()[0]
    }
    
    static func createPortfolio(){
        if !doesPortfolioExist() {
            let viewContext = PersistenceController.shared.getContext()
            let portfolio = Portfolio(context: viewContext)
            portfolio.total = getPortfolioTotal()
        }
    }
    
    static func getPortfolioTotal() -> Double {
        var sum = 0.0
        DispatchQueue.main.async {
            for stock in Stock.getStocks() {
                sum += stock.shares * stock.price
            }
        }
        print(sum)
        return sum
    }
    
    static func updatePortfolioTotal(){
        getPortfolio().total = getPortfolioTotal()
    }
    
    static func doesPortfolioExist() -> Bool{
        return getPortfolios().count > 0
    }
}
