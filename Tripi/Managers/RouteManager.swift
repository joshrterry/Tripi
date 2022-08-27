//
//  RouteManager.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-02.
//

import Foundation
import MapKit
import Combine
import CoreLocation
import SwiftUI


class RouteManager: NSObject, ObservableObject {
    @Published var trackingState: TrackingState = .active
    private var locationManager: CLLocationManager!
    
    typealias Output = (longitude: Double, latitude: Double)
    typealias Failure = Never
    private let wrapped = PassthroughSubject<(Output), Failure>()
    
    override init() {
        super.init()
        locationManagerConfig()
//        DispatchQueue.main.asyncAfter(deadline: .now()+10) {
//            self.trackingState = .inactive
//        }
    }
    
    private func locationManagerConfig() {
        locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    public func startRoute() {
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.trackingState = .active
    }
    
    public func stopRoute() {
        locationManager.allowsBackgroundLocationUpdates = false
        trackingState = .inactive
    }
    
    public func toggleTrip() {
        if trackingState == .active {
            stopRoute()
        } else {
            startRoute()
        }
    }
    
//    public func generateMultiPolyline() -> MKMultiPolyline {
//        var polylines: [MKPolyline] = []
//        
//        polylines.append(MKPolyline(coordinates: CLLocationCoordinate2D(latitude: CLLocation.coordinate.latitude, longitude: CLLocation.coordinate.longitude), count: locations.count))
//    }
        
}
    
extension RouteManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if trackingState != .active { return }
        guard let location = locations.last else { return }
        wrapped.send((longitude: location.coordinate.longitude, latitude: location.coordinate.latitude))
    }
}

extension RouteManager: Publisher {
    func receive<Downstream: Subscriber>(subscriber: Downstream) where Failure == Downstream.Failure, Output == Downstream.Input {
        wrapped.subscribe(subscriber)
    }
}

