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
    @Published var trackingState: TrackingState = .inactive
    @Published var distanceTotal = 0.0
    @Published var time = "00:00"
    @Published var averageSpeed = 0.0
    @Published var currentSpeed = 0.0
    @Published var routeWaypoints: [CLLocationCoordinate2D] = []
    @Published var startTime = Date()
    var lastTwoLocations: [CLLocation] = []

    @Published var secondsElapsed = 0.0
    
    var timerStartTime: Date = Date()
    
    var timer = Timer()
    
    func startTimer() {
        timerStartTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
            let current = Date()
            let diffComponents = Calendar.current.dateComponents([.second, .nanosecond], from: self.timerStartTime, to: current)
            let seconds = Double(diffComponents.second ?? 0) + Double(diffComponents.nanosecond ?? 0) / 1000000000
            self.secondsElapsed += seconds
            secondstoMinutesSeconds(seconds: secondsElapsed.self)
            getAvgSpeed()
            getCurrentSpeed()
            self.timerStartTime = current
        }
    }
    
    func pauseTimer() {
        timer.invalidate()
    }
    
    func resetTimer() {
        timer.invalidate()
        secondsElapsed = 0
        time = "00:00"
    }
    
    func secondstoMinutesSeconds(seconds: Double) {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior  = .pad
        
        self.time = formatter.string(from: TimeInterval(seconds))!
    }
    private var lastLocation: CLLocation!
    
    private var locationManager: CLLocationManager!
    
    typealias Output = (longitude: Double, latitude: Double)
    typealias Failure = Never
    private let wrapped = PassthroughSubject<(Output), Failure>()
    
    override init() {
        super.init()
        locationManagerConfig()
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
        startTimer()
        startTime = Date()
    }
    
    public func stopRoute() {
        PersistenceController.shared.addTrip(distance: distanceTotal, time: time, speed: averageSpeed, startTime: startTime, endTime: Date())
        locationManager.allowsBackgroundLocationUpdates = false
        trackingState = .inactive
        lastLocation = nil
        distanceTotal = 0
        currentSpeed = 0
        averageSpeed = 0
        resetTimer()
    }
    
    public func toggleTrip() {
        if trackingState == .active {
            stopRoute()
        } else {
            startRoute()
        }
    }
    
    private func getAvgSpeed() {
        averageSpeed = (distanceTotal)/(secondsElapsed/3600)
    }
    
    private func getCurrentSpeed() {
        if lastTwoLocations.count == 2 {
            currentSpeed = (lastTwoLocations[1].distance(from: lastTwoLocations[0])/1000)/(lastTwoLocations[1].timestamp.timeIntervalSince(lastTwoLocations[0].timestamp)/3600)

        }
    }
    
        
}
    
extension RouteManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if trackingState != .active { return }
        guard let location = locations.last else { return }
        if lastLocation != nil {
            distanceTotal += location.distance(from: lastLocation) / 1000
            routeWaypoints.append(lastLocation.coordinate)
            lastTwoLocations = []
            lastTwoLocations.append(lastLocation)
            lastTwoLocations.append(location)
        }
        wrapped.send((longitude: location.coordinate.longitude, latitude: location.coordinate.latitude))
        lastLocation = location
    }
}

extension RouteManager: Publisher {
    func receive<Downstream: Subscriber>(subscriber: Downstream) where Failure == Downstream.Failure, Output == Downstream.Input {
        wrapped.subscribe(subscriber)
    }
}

