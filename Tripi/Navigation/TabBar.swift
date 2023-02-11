//
//  TabBar.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-01.
//
// CONSOLE: withAnimation causing "Missing MeshRenderables for ground mesh..."

import SwiftUI

struct TabBar: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("selectedTab") var selectedTab: Tab = .home
    @AppStorage("selectedUnits") var selectedUnits = "metric"
    @EnvironmentObject var routeManager: RouteManager
    @State var showLiveMetrics = false
    let unitFormatter = UnitFormatter()
    
    var body: some View {
            VStack {
                Spacer()
                ZStack(alignment: .bottom) {
                    
                    ZStack(alignment: .top) {
                        Rectangle()
                            .frame(maxWidth: .infinity, maxHeight: 210)
                            .foregroundColor(colorScheme == .dark ? Color("TripiDark") : Color(.systemGray6))
                            .cornerRadius(30)
                            .shadow(color: .primary.opacity(0.05), radius: 7, x: -5, y: -5)
                        HStack() {
                            Metric(data: "\(unitFormatter.formatDistance(distance: routeManager.distanceTotal, selectedUnits: selectedUnits))", descriptor: selectedUnits == "metric" ? "KM Travelled" : "MI Travelled", color: .primary)
                                .frame(width: 100)
                            Metric(data: routeManager.time, descriptor: "Time Elapsed", color: .primary)
                                .frame(width: 120)
                            Metric(data: "\(Int(unitFormatter.formatSpeed(speed: routeManager.currentSpeed, selectedUnits: selectedUnits)))", descriptor: selectedUnits == "metric" ? "Current KPH" : "Current MPH", color: .primary)
                                .frame(width: 100)
                        }
                        .padding(.top, 22)
                    }
                    .offset(y: showLiveMetrics ? 0 : 120)
                


                    
                    ZStack(alignment: .top) {
                        Rectangle()
                            .frame(maxWidth: .infinity, maxHeight: 90)
                            .foregroundColor(colorScheme == .dark ? Color("TripiDark") : .white)
                            .cornerRadius(30)
                            .shadow(color: .primary.opacity(0.05), radius: 7, x: -5, y: -5)
                        HStack(spacing: 45) {
                            Group {
                                Button {
                                    selectedTab = .home
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
                                        
                                    Button {
                                        if selectedTab == .route {
                                            routeManager.toggleTrip()
                                        } else {
                                            selectedTab = .route

                                        }
                                        withAnimation {
                                            showLiveMetrics = true
                                        }
                                        print(routeManager.trackingState)

                                    } label: {
                                        if selectedTab == .route {
                                            if routeManager.trackingState == .inactive {
                                                Image("go_icon")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 45, height: 45)
                                                    .foregroundColor(.black)
                                                    .font(.system(size: 50))
                                            }
                                            if routeManager.trackingState == .active {
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
            }
            .edgesIgnoringSafeArea(.all)
            }
        }


struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar()
    }
}
