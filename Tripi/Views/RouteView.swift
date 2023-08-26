//
//  RouteView.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-01.
//

import SwiftUI
import MapKit
import CoreData

struct RouteView: View {
    @ObservedObject var model: Model
    @EnvironmentObject var routeManager: RouteManager
    @State private var showingPause = false
    @State private var hasHomeButton = false
    @State private var activites = [""]
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Location.timestamp, ascending: true)], animation: .default)
    private var locations: FetchedResults<Location>
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Color("Background").ignoresSafeArea()
                ZStack(alignment: .topTrailing) {
                    VStack {
                        // full screen map with route overlays
                        PolylineMap(region: $region, routeCoordinates: $routeManager.routeWaypoints, isTracking: true, edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 65, right: 0))
                            .frame(height: hasHomeButton ? geometry.size.height * 0.58 : geometry.size.height * 0.68)
                            .cornerRadius(50, corners: [.topLeft, .topRight])
                            .shadow(color: .primary.opacity(0.15), radius: 20, x: -5, y: -5)
                            .onChange(of: routeManager.trackingState) { newValue in // if trip in progress, show pause/resume buttons
                                if routeManager.trackingState != .inactive {
                                    withAnimation {
                                        showingPause = true
                                    }
                                } else {
                                    withAnimation {
                                        showingPause = false
                                    }
                                }
                            }
                            .onAppear {
                                if routeManager.trackingState != .inactive {
                                    withAnimation {
                                        showingPause = true
                                    }
                                } else {
                                    withAnimation {
                                        showingPause = false
                                    }
                                }
                            }
                        Spacer()
                            .frame(height: 150)
                    }
                    .edgesIgnoringSafeArea(.all)

                    
                    if showingPause {
                        // dynamic pause and resume buttons
                        ZStack {
                            Rectangle()
                                .foregroundStyle(.thinMaterial)
                                .frame(width: 50, height: 50)
                                .cornerRadius(20)
                            Button {
                                withAnimation {
                                    routeManager.togglePause()
                                }
                            } label: {
                                Image(systemName: (routeManager.trackingState == .active ? "pause" : "play"))
                                    .font(.system(size: 28, weight: .heavy))
                                    .foregroundColor(.primary)
                            }
                        }
                        .zIndex(1)
                        .padding(20)
                    }
//                    Text("hello")
                    Text("\(activites.joined())")
                        .background(.red)
                }

            }
            .onChange(of: routeManager.recentActivities, perform: { newValue in
                activites = routeManager.recentActivities.map{String($0)}
                print(routeManager.currentActivity)

            })
            .edgesIgnoringSafeArea(.all)
            .overlay(!model.fullScreen ? NavigationBar(showingButttons: false,  title: "New Trip", hasScrolled: .constant(false)) : nil)
            .onAppear {
                if geometry.safeAreaInsets.bottom == 0.0 {
                    hasHomeButton = true
                } else {
                    hasHomeButton = false
                }
            }
        }
    }
}

