//
//  ContentView.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-02.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("selectedTab") var selectedTab: Tab = .home
    @StateObject var model: Model = Model()
    @EnvironmentObject var routeManager: RouteManager
    @AppStorage("showingTabBar") var showingTabBar: Bool = true
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Display the appropriate tab based on selectedTab variable
            switch selectedTab {
            case .home:
                HomeView()
            case .route:
                RouteView(model: model)
            case .trips:
                TripBrowserView()
            }
            
            // Tab bar at bottom of screen
            TabBar()
                .offset(y: model.fullScreen ? 200 : 0)
                .coordinateSpace(name: "TabBar")
        }
        // Inject routeManager instance into the various subviews
        .environmentObject(routeManager)
    }
}
