//
//  TabBar.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-01.
//

import SwiftUI

struct TabBar: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("selectedTab") var selectedTab: Tab = .home
    @AppStorage("selectedUnits") var selectedUnits = "metric"
    @EnvironmentObject var routeManager: RouteManager
    @AppStorage("liveMetrics") var liveMetrics = false
    @AppStorage("showingTabBar") var showingTabBar: Bool = true

    @State var showLiveMetrics = false
    @State var showTabBar = true
    let unitFormatter = UnitFormatter()
    
    var body: some View {
        VStack {
            Spacer()
            ZStack(alignment: .bottom) {
                
                // live metrics that appear in routeview
                ZStack(alignment: .top) {
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: 210)
                        .foregroundColor(colorScheme == .dark ? Color("TripiDark") : Color(.systemGray6))
                        .cornerRadius(30)
                        .shadow(color: .primary.opacity(0.05), radius: 7, x: -5, y: -5)
                    HStack() {
                        // distance travelled
                        Metric(data: "\(unitFormatter.formatDistance(distance: routeManager.distanceTotal, selectedUnits: selectedUnits))", descriptor: selectedUnits == "metric" ? "KM Travelled" : "MI Travelled", color: .primary)
                            .frame(width: 100)
                        // trip duration
                        Metric(data: routeManager.time, descriptor: "Time Elapsed", color: .primary)
                            .frame(width: 120)
                        // current speed
                        Metric(data: "\(Int(unitFormatter.formatSpeed(speed: routeManager.currentSpeed, selectedUnits: selectedUnits)))", descriptor: selectedUnits == "metric" ? "Current KPH" : "Current MPH", color: .primary)
                            .frame(width: 100)
                    }
                    .padding(.top, 22)
                }
                .onAppear {
                    if selectedTab == .route {
                        showLiveMetrics = liveMetrics
                    }
                }
                .onDisappear {
                    liveMetrics = showLiveMetrics
                }
                .offset(y: showLiveMetrics ? 0 : 120) // if routeview is not selected, offset elements beneath the screen safe area
                
                
                ZStack(alignment: .top) {
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: 90)
                        .foregroundColor(colorScheme == .dark ? Color("TripiDark") : .white)
                        .cornerRadius(30)
                        .shadow(color: .primary.opacity(0.05), radius: 7, x: -5, y: -5)
                    
                    // buttons for switching tabs
                    HStack(spacing: 45) {
                        Group {
                            // HomeView
                            Button {
                                withAnimation {
                                    selectedTab = .home
                                }
                                withAnimation {
                                    showLiveMetrics = false
                                }
                            } label: {
                                Image(systemName: "house.fill")
                                    .foregroundColor(selectedTab == .home ? .primary : .secondary)
                            }
                            ZStack {
                                Circle()
                                    .foregroundColor(colorScheme == .dark ? Color("TripiDark") : .white)
                                    .frame(width: 62, height: 62)
                                    .shadow(color: .primary.opacity(0.1), radius: 20, x: 10, y: 10)
                                    .shadow(color: .primary.opacity(0.1), radius: 20, x: -5, y: -5)
                                
                                // RouteView
                                Button {
                                    if selectedTab == .route {
                                        routeManager.toggleTrip()
                                    } else {
                                        withAnimation {
                                            selectedTab = .route
                                        }
                                    }
                                    withAnimation {
                                        showLiveMetrics = true
                                    }
                                } label: {
                                    // icon depends on whether trip is currently in progress
                                    if selectedTab == .route {
                                        if routeManager.trackingState == .inactive {
                                            Image("go_icon")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 45, height: 45)
                                                .foregroundColor(.black)
                                                .font(.system(size: 50))
                                        }
                                        else {
                                            Image("stop_icon")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 45, height: 45)
                                                .foregroundColor(.black)
                                                .font(.system(size: 50))
                                        }
                                    } else {
                                        Image("tripimono")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 45, height: 45)
                                            .foregroundColor(.black)
                                            .font(.system(size: 50))
                                    }
                                    
                                }
                            }
                            .offset(y: -10)
                            
                            // TripBrowser
                            Button {
                                selectedTab = .trips
                                withAnimation {
                                    showLiveMetrics = false
                                }
                            } label: {
                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(selectedTab == .trips ? .primary : .secondary)
                            }
                        }
                        .font(.system(size: 24, weight: .bold))
                    }
                    
                }
            }
            .onAppear {
                withAnimation {
                    showTabBar = showingTabBar
                }
            }
            .onChange(of: showingTabBar, perform: { newValue in
                withAnimation {
                    showTabBar = newValue
                }
            })
            .onDisappear {
                withAnimation {
                    showingTabBar = showTabBar
                }
            }
            .offset(y: showTabBar ? 0 : 120)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
