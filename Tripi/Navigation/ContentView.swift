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
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
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
            }
            if !hasOnboarded {
                OnboardingView()
                    .background()
                    .onAppear {
                        PersistenceController.shared.addTag(name: "Business", colour: [163.0, 196.0, 243.0], reimbursementAmount: 0.50)
                        PersistenceController.shared.addTag(name: "Personal", colour: [241.0, 192.0, 232.0], reimbursementAmount: 0.0)
                    }
            }

        }
        .onAppear {
            // showingTabBar is persisted, so reset it in case the app was closed while a detail view had it hidden
            showingTabBar = true
        }
        // Inject routeManager instance into the various subviews
            .environmentObject(routeManager)
    }
}
