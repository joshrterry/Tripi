//
//  TripiApp.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-06-12.
//

import Combine
import SwiftUI

@main
struct TripiApp: App {
    let routeManager = RouteManager()
    var cancellables = [AnyCancellable]()
     
    init() {
        if routeManager.trackingState == .active {
            routeManager.sink(receiveValue: PersistenceController.shared.add).store(in: &cancellables)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
}
