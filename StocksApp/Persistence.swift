//
//  Persistence.swift
//  StocksApp
//
//  Created by Hunter Kingsbeer on 29/06/21.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let portfolio = Portfolio(context: viewContext)
        portfolio.total = 0
        
        let stock1 = Stock(context: viewContext)
        stock1.id = UUID()
        stock1.title = "Meridian Energy"
        stock1.symbol = "MEL"
        stock1.usd = false
        stock1.shares = 225
        stock1.input = 1413.49
        stock1.category = "power"
        
        let stock2 = Stock(context: viewContext)
        stock2.id = UUID()
        stock2.title = "Enphase Energy"
        stock2.symbol = "ENPH"
        stock2.usd = true
        stock2.shares = 9
        stock2.input = 755 + 537
        stock2.category = "clean"
        
        let stock3 = Stock(context: viewContext)
        stock3.id = UUID()
        stock3.title = "Apple"
        stock3.symbol = "AAPL"
        stock3.usd = true
        stock3.shares = 3.2847 + 5.0
        stock3.input = 401.28 + 661
        stock3.category = "tech"
        
        let stock4 = Stock(context: viewContext)
        stock4.id = UUID()
        stock4.title = "Tesla"
        stock4.symbol = "TSLA"
        stock4.usd = true
        stock4.shares = 1.47 + 1
        stock4.input = 765 + 868
        stock4.category = "cars"
        
        save()
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "StocksApp")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    func getContext() -> NSManagedObjectContext {
        return container.viewContext
    }
    static func save() {
        let viewContext = shared.getContext()
        do {
            try  viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

}
