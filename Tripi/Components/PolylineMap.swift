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
    
    // Create the MKMapView using UIKit.
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = region
        mapView.showsCompass = false
        if isTracking {
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
        mapView.isScrollEnabled = false
        
        mapView.layoutMargins = edgeInsets
        let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(polyline)
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.tintColor = routeManager.trackingState == .active ? UIColor.systemBlue : UIColor.systemGray
        let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
        view.removeOverlays(view.overlays)
        view.addOverlay(polyline)
        
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: PolylineMap
        
        init(_ parent: PolylineMap) {
            self.parent = parent
        }
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let routePolyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: routePolyline)
                renderer.strokeColor = UIColor.systemBlue
                renderer.lineWidth = 7
                
                
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}



//struct Map_Previews: PreviewProvider {
//    static var previews: some View {
//        Map()
//    }
//}
