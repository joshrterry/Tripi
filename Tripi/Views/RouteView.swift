//
//  RouteView.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-01.
//

import SwiftUI
import MapKit
import Combine

struct RouteView: View {
    @ObservedObject private var locationManager = LocationManager() 
    @EnvironmentObject var model: Model

    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            VStack {
                if !model.fullScreen {
                    Spacer()
                        .frame(height: 150)
                }
        
                Map(coordinateRegion: $locationManager.region, interactionModes: [], showsUserLocation: true, userTrackingMode: .constant(.follow))
                    .cornerRadius(50, corners: [.topLeft, .topRight])
                    .shadow(color: .primary.opacity(0.15), radius: 20, x: -5, y: -5)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .overlay(!model.fullScreen ? NavigationBar(title: "New Trip", hasScrolled: .constant(false)) : nil)
        .onAppear {
            locationManager.checkLocationServices()
        }

    }
}

struct RouteView_Previews: PreviewProvider {
    static var previews: some View {
        RouteView().environmentObject(Model())
    }
}

//    .onAppear {
//        MKMapView.appearance().mapType = .mutedStandard
//    }
