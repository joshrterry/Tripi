//
//  ContentView.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-02.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("selectedTab") var selectedTab: Tab = .home
    @EnvironmentObject var model: Model

    var body: some View {
        ZStack(alignment: .bottom) {
            switch selectedTab {
            case .home:
                HomeView()
            case .route:
                RouteView()
            case .trips:
                HomeView()
            }
            TabBar()
                .offset(y: model.fullScreen ? 200 : 0)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
                .preferredColorScheme(.dark)
        }
        .environmentObject(Model())
    }
}
