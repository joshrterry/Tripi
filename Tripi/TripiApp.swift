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
    @StateObject private var routeManager: RouteManager
    var cancellables = [AnyCancellable]()

    init() {
       // Creates a new instance of RouterManager (the one and only)
       let routeManager = RouteManager()
       // Stores the newly created instance in the StateObject property
       _routeManager = .init(wrappedValue: routeManager)
       // Subscribes to the events of RouteManager
       routeManager
           .sink(receiveValue: PersistenceController.shared.addLocation).store(in: &cancellables)
    }
    var body: some Scene {
        WindowGroup {
           ContentView()
               .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext) 
               .environmentObject(routeManager)
       }
   }
}
