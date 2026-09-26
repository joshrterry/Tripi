//
//  PolylineMap.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-08-29.
//

import SwiftUI
import MapKit

struct PolylineMap: UIViewRepresentable {
    @EnvironmentObject var routeManager: RouteManager
    
    @Binding var region: MKCoordinateRegion
    @Binding var routeCoordinates: [CLLocationCoordinate2D]
    @State var isTracking: Bool
    @State var edgeInsets: UIEdgeInsets
    
    // create the MKMapView using UIKit
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        // start on the last known location when tracking so the map doesn't open on 0,0 before the first fix
        if isTracking, let coordinate = routeManager.locationManager?.location?.coordinate {
            mapView.region = MKCoordinateRegion(center: coordinate, span: region.span)
        } else {
            mapView.region = region
        }
        mapView.showsCompass = false
        // center map on user location
        if isTracking {
            mapView.showsUserLocation = true
            
            // slight delay to properly fetch current location first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                mapView.userTrackingMode = .follow
            }
        }
        mapView.isScrollEnabled = false
        
        // ensure watermark is within view margins
        mapView.layoutMargins = edgeInsets
        
        // generate polyline
        let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(polyline)
        context.coordinator.drawnCoordinateCount = routeCoordinates.count
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.tintColor = routeManager.trackingState == .active ? UIColor.systemBlue : UIColor.systemGray
        // update polyline only when the route has changed, since this runs on every published update
        guard routeCoordinates.count != context.coordinator.drawnCoordinateCount else { return }
        let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
        view.removeOverlays(view.overlays)
        view.addOverlay(polyline)
        context.coordinator.drawnCoordinateCount = routeCoordinates.count
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: PolylineMap
        var drawnCoordinateCount = 0
        
        init(_ parent: PolylineMap) {
            self.parent = parent
        }
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let routePolyline = overlay as? MKPolyline {
                // customize polyline properties
                let renderer = MKPolylineRenderer(polyline: routePolyline)
                renderer.strokeColor = UIColor.systemBlue
                renderer.lineWidth = 7
                
                
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}
