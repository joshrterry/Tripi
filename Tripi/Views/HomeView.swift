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
                        SummaryStats(filters: [startDateOfMonth, startDateOfWeek])
                        RecentTrips()
                    }
                }
                .coordinateSpace(name: "scroll")
                .safeAreaInset(edge: .top, content: {
                    Color.clear.frame(height: 50)
                })
                .overlay(NavigationBar(title: "Dashboard", hasScrolled: $hasScrolled))
                .navigationBarHidden(true)
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
                if value < 0 {
                    hasScrolled = true
                } else {
                    hasScrolled = false
                }
            }
        })
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(RouteManager())
        
    }
}
