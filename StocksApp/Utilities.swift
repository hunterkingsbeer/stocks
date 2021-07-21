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
