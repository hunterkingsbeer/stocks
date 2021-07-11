//
//  Utilities.swift
//  StocksApp
//
//  Created by Hunter Kingsbeer on 4/07/21.
//

import Foundation
import SwiftUI
import CoreData
import Swift



extension Stock {
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
        print("New stock: \(title) folder")
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
            print("Error fetching Folders: \(error.localizedDescription), \(error.userInfo)")
          }
        return [Stock]()
    }
    
    /// Deletes a stock
    static func delete(stock: Stock) {
        let viewContext = PersistenceController.shared.getContext()
        print("Deleted folder: \(String(describing: stock.title))")
        viewContext.delete(stock)
        save()
    }
    
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
    
    static func color(stockMode: StockMode, pendingDelete: Bool) -> String {
        return stockMode == .editing ? "yellow" : stockMode == .deleting ? pendingDelete ? "red" : "accent" : "accent"
    }
    
    func doesStockExist(stock: Stock) {
        
    }
}

func csvToArray(csv: String) -> [String] {
    return csv.components(separatedBy: ",")
}

func arrayToCSV(arr: [String]) -> String {
    return (arr.map{String($0)}).joined(separator: ",")
}

/// Shrinking a=nimation for the UI buttons.
struct ShrinkingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.spring())
    }
}

// Normal TextField doesn't allow colored placeholder text, this does. SOLUTION FOUND AT THIS LINK https://stackoverflow.com/questions/57688242/swiftui-how-to-change-the-placeholder-color-of-the-textfield
/// Workaround to allow for coloured placeholder text.
struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var editingChanged: (Bool)->() = { _ in }
    var commit: ()->() = { }

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { Text(placeholder) }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
        }
    }
}
