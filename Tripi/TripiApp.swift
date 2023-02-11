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
    //    private var activityManager: ActivityManager
    
    
    init() {
        // Creates a new instance of RouterManager to be used throughout the app
        let routeManager = RouteManager()
        // Stores the instance in the StateObject property
        _routeManager = .init(wrappedValue: routeManager)
        // Subscribes to the events of RouteManager
        routeManager
            .sink(receiveValue: PersistenceController.shared.addLocation).store(in: &cancellables)
        
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            // Inject routeManager instance into the ContextView()
                .environmentObject(routeManager)
        }
    }
}
