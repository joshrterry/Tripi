//
//  RouteManager.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-02.
//

import Combine
import CoreLocation
import Foundation
import SwiftUI


class RouteManager: NSObject, ObservableObject {
    @Published var trackingState: TrackingState = .inactive

    typealias Output = (longitude: Double, latitude: Double)
    typealias Failure = Never
    private let wrapped = PassthroughSubject<(Output), Failure>()
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.activityType = .automotiveNavigation
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.allowsBackgroundLocationUpdates = true
        //self.locationManager.pausesLocationUpdatesAutomatically = false // throws "Non-UI clients cannot be autopaused"
        self.locationManager.startUpdatingLocation()
    }
}

extension RouteManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // FIX THIS
        if self.trackingState != .active { return }
        guard let location = locations.last else { return }
        wrapped.send((longitude: location.coordinate.longitude, latitude: location.coordinate.latitude))
    }
}

extension RouteManager: Publisher {
    func receive<Downstream: Subscriber>(subscriber: Downstream) where Failure == Downstream.Failure, Output == Downstream.Input {
        wrapped.subscribe(subscriber)
    }
}

//
//enum MapDetails {
//    static let defaultLocation = CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090)
//    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
//
//}
//final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    @Published var region = MKCoordinateRegion(center: MapDetails.defaultLocation, span: MapDetails.defaultSpan)
//
//    var locationManager: CLLocationManager?
//
//    func checkLocationServices() {
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager = CLLocationManager()
//            locationManager!.delegate = self
//            locationManager?.activityType = .automotiveNavigation
//            locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//        } else {
//            // ask to enable location services
//        }
//    }
//
//    private func checkLocationAuthorization() {
//        guard let locationManager = locationManager else { return }
//
//        switch locationManager.authorizationStatus {
//
//        case .notDetermined:
//            locationManager.requestAlwaysAuthorization()
//        case .restricted:
//            print("restricted due to parental controls")
//        case .denied:
//            print("go into settings to change")
//        case .authorizedAlways, .authorizedWhenInUse:
//            region = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
//        @unknown default:
//            break
//        }
//    }
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        checkLocationAuthorization()
//    }
//}
//
