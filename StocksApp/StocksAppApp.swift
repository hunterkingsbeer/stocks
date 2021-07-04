//
//  StocksAppApp.swift
//  StocksApp
//
//  Created by Hunter Kingsbeer on 29/06/21.
//

import SwiftUI

@main
struct StocksAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
