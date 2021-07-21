//
//  UserSettings.swift
//  StocksApp
//
//  Created by Hunter Kingsbeer on 21/07/21.
//

import Foundation
import SwiftUI
import Combine

/// Class of settings that the user may specify, impacting the interface.
class UserSettings: ObservableObject {
    @Published var darkMode: Bool {
        didSet {
            UserDefaults.standard.set(darkMode, forKey: "darkMode")
        }
    }

    /// Default settings.
    init() {
        /// Dark mode.
        self.darkMode = UserDefaults.standard.object(forKey: "darkMode") as? Bool ?? true
    }
}
