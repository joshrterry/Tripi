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
    @AppStorage("showingTabBar") var showingTabBar: Bool = true
    @AppStorage("hasHomeButton") var hasHomeButton = false

    let unitFormatter = UnitFormatter()
    @State private var showingEndTripConfirmation = false
    
    // live metrics are shown whenever routeview is the selected tab
    private var showLiveMetrics: Bool {
        selectedTab == .route
    }
    
    var body: some View {
        VStack {
            Spacer()
            ZStack(alignment: .bottom) {
                
                // live metrics that appear in routeview
                ZStack(alignment: .top) {
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: 210)
                        .foregroundColor(colorScheme == .dark ? Color("TripiDark") : Color(.systemGray6))
                        .cornerRadius(30, corners: [.topLeft, .topRight])
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
                .offset(y: showLiveMetrics ? 0 : 120) // if routeview is not selected, offset elements beneath the screen safe area
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: showLiveMetrics)
                
                
                ZStack(alignment: .top) {
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: 90)
                        .foregroundColor(colorScheme == .dark ? Color("TripiDark") : .white)
                        .cornerRadius(30, corners: [.topLeft, .topRight])
                        .shadow(color: .primary.opacity(0.05), radius: 7, x: -5, y: -5)
                    
                    // buttons for switching tabs
                    HStack(spacing: 30) {
                        Group {
                            // HomeView
                            Button {
                                selectedTab = .home
                            } label: {
                                Image(systemName: "house.fill")
                                    .foregroundColor(selectedTab == .home ? .primary : .secondary)
                                    .padding()
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
                                        if routeManager.trackingState == .inactive {
                                            routeManager.toggleTrip()
                                        } else {
                                            // confirm before ending so a stray tap while driving doesn't cut a trip short
                                            showingEndTripConfirmation = true
                                        }
                                    } else {
                                        selectedTab = .route
                                    }
                                } label: {
                                    // icon depends on whether trip is currently in progress
                                    Image(centerIconName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 45, height: 45)
                                        .foregroundColor(.black)
                                        .font(.system(size: 50))
                                        .id(centerIconName)
                                        .transition(.scale(scale: 0.6).combined(with: .opacity))
                                }
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: centerIconName)
                                .confirmationDialog("End this trip?", isPresented: $showingEndTripConfirmation, titleVisibility: .visible) {
                                    Button("End Trip", role: .destructive) {
                                        routeManager.toggleTrip()
                                    }
                                }
                            }
                            .offset(y: -10)
                            
                            // TripBrowser
                            Button {
                                selectedTab = .trips
                            } label: {
                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(selectedTab == .trips ? .primary : .secondary)
                                    .padding()
                            }
                        }
                        .font(.system(size: 24, weight: .bold))
                    }
                    
                }
            }
            // haptic feedback whenever a trip starts, stops, pauses, or resumes
            .sensoryFeedback(trigger: routeManager.trackingState) { oldState, newState in
                switch (oldState, newState) {
                case (.inactive, _): return .start
                case (_, .inactive): return .stop
                default: return .impact(weight: .medium)
                }
            }
            .offset(y: showingTabBar ? 0 : 120)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: showingTabBar)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // image for the center button: tripi logo off the route tab, otherwise go/stop depending on trip state
    private var centerIconName: String {
        guard selectedTab == .route else { return "tripimono" }
        return routeManager.trackingState == .inactive ? "go_icon" : "stop_icon"
    }
}
