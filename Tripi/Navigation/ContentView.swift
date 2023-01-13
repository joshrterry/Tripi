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
            switch selectedTab {
            case .home:
                HomeView()
            case .route:
                RouteView(model: model)
            case .trips:
                TripBrowserView()
            }
//            if showingTabBar {
//                withAnimation {
                    TabBar()
                        .offset(y: model.fullScreen ? 200 : 0)
//                }
//            }

        }
        .environmentObject(routeManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
                .preferredColorScheme(.dark)
        }
        .environmentObject(RouteManager())
    }
}
