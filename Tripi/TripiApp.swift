//
//  TripiApp.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-06-12.
//

import SwiftUI

@main
struct TripiApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(Model())
        }
    }
}
