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

    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Location.timestamp, ascending: true)], animation: .default)
    private var locations: FetchedResults<Location>
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            VStack {
                if !model.fullScreen {
//                    Spacer()
//                        .frame(height: )
                }
        
                PolylineMap(region: $region, routeCoordinates: $routeManager.routeWaypoints, isTracking: true, edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0))

                .frame(height: 500)
                .cornerRadius(50, corners: [.topLeft, .topRight])
                .shadow(color: .primary.opacity(0.15), radius: 20, x: -5, y: -5)
                .edgesIgnoringSafeArea(.all)
  
            }
        }
        .overlay(!model.fullScreen ? NavigationBar(showingButttons: false,  title: "New Trip", hasScrolled: .constant(false)) : nil)

    }
}

struct RouteView_Previews: PreviewProvider {
    static var previews: some View {
        RouteView(model: Model()).environmentObject(RouteManager())
    }
}

//    .onAppear {
//        MKMapView.appearance().mapType = .mutedStandard
//    }
