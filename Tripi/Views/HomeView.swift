//
//  ContentView.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-06-12.
//

import SwiftUI
import CoreData
import MapKit

struct HomeView: View {
    @EnvironmentObject var routeManager: RouteManager
    @AppStorage("showingTabBar") var showingTabBar: Bool = true

    @State var hasScrolled = false
    @State var currentDate = Date()
    
    var startDateOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: currentDate)
        let startOfMonth = Calendar.current.date(from: components)!
        return startOfMonth
    }
    
    var startDateOfWeek: Date {
        let components = Calendar.current.dateComponents([.yearForWeekOfYear,  .weekOfYear], from: currentDate)
        let startOfWeek = Calendar.current.date(from: components)!
        return startOfWeek
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").ignoresSafeArea()                
                ScrollView {
                    scrollDetection
                    VStack {
                        // monthly and weekly metrics at top of view
                        SummaryStats(filters: [startDateOfMonth, startDateOfWeek])
                        // displays trip previews for past 7 days
                        RecentTrips()
                    }
                }
                .coordinateSpace(name: "scroll") // used to monitor scroll position
                .safeAreaInset(edge: .top, content: {
                    Color.clear.frame(height: 50)
                })
                .safeAreaInset(edge: .bottom, content: {
                    Color.clear.frame(height: 100)
                })
                .overlay(NavigationBar(title: "Dashboard", hasScrolled: $hasScrolled))
                .navigationBarHidden(true)
            }
            .onAppear {
                showingTabBar = true
            }
        }
    }
    
    var scrollDetection: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: ScrollPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)
        }
        .frame(height: 0)
        .onPreferenceChange(ScrollPreferenceKey.self, perform: { value in
            withAnimation(.easeInOut) {
                // if user scrolls down, shrink the nav bar
                if value < 0 {
                    hasScrolled = true
                } else {
                    hasScrolled = false
                }
            }
        })
    }
}
