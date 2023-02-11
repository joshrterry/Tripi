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
    let activityManager = ActivityManager()
    
    var lastTwoLocations = (last: CLLocation(latitude: 0, longitude: 0), current: CLLocation(latitude: 0, longitude: 0))
    
    // Creates new instance of Trip
    var newTrip: Trip = Trip()
    
    @Published var secondsElapsed = 0.0
    
    var timerStartTime: Date = Date()
    
    var timer = Timer()
    
    // Start a timer to track the duration of the trip
    func startTimer() {
        timerStartTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
            let current = Date()
            let diffComponents = Calendar.current.dateComponents([.second, .nanosecond], from: self.timerStartTime, to: current)
            let seconds = Double(diffComponents.second ?? 0) + Double(diffComponents.nanosecond ?? 0) / 1000000000
            self.secondsElapsed += seconds
            self.time = secondstoMinutesSeconds(seconds: secondsElapsed.self)
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
    
    public func secondstoMinutesSeconds(seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior  = .pad
        
        return formatter.string(from: TimeInterval(seconds))!
    }
    
    public func secondstoHours(seconds: Double) -> Double {
        return seconds/3600
    }
    
    private var lastLocation: CLLocation!
    
    private var locationManager: CLLocationManager!
    
    typealias Output = (longitude: Double, latitude: Double, speed: Double, trip: Trip)
    typealias Failure = Never
    private let dataPublisher = PassthroughSubject<(Output), Failure>()
    
    
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
        activityManager.startMotionUpdates()
        startTimer()
        startTime = Date()
        newTrip = PersistenceController.shared.addTrip(startTime: startTime)
        
    }
    
    public func stopRoute() {
        PersistenceController.shared.editTrip(trip: newTrip, distance: distanceTotal, time: time, speed: averageSpeed, startTime: startTime, endTime: Date(), seconds: secondsElapsed)
        locationManager.allowsBackgroundLocationUpdates = false
        trackingState = .inactive
        activityManager.stopMotionUpdates()
        lastLocation = nil
        distanceTotal = 0
        currentSpeed = 0
        averageSpeed = 0
        routeWaypoints = []
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
        currentSpeed = (lastTwoLocations.current.distance(from: lastTwoLocations.last)/1000)/(lastTwoLocations.current.timestamp.timeIntervalSince(lastTwoLocations.last.timestamp)/3600)
    }
    
    
}

extension RouteManager: CLLocationManagerDelegate {
    // delegate method called upon a device location update, calculates relevant metrics, and publishes to subscriber
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if trackingState != .active { return } // exit function if user is not currently logging a trip
        guard let location = locations.last else { return }
        
        // error handling to prevent situations at the start of a trip when the program attempts to calcualate distance from last waypoint, and no other points exist
        if lastLocation != nil {
            distanceTotal += location.distance(from: lastLocation) / 1000 // divide by 1000 to convert m to km
            routeWaypoints.append(lastLocation.coordinate)
            lastTwoLocations.last = lastLocation
            lastTwoLocations.current = location
        }
        
        // publishes coordinate and trip data to subscriber via dataPublisher instance
        dataPublisher.send((longitude: location.coordinate.longitude, latitude: location.coordinate.latitude, speed: currentSpeed, trip: newTrip))
        
        // set lastLocation variable to the current location for this iteration
        lastLocation = location
    }
}

extension RouteManager: Publisher {
    // subscribes a new subscriber to the dataPublisher
    func receive<Downstream: Subscriber>(subscriber: Downstream) where Failure == Downstream.Failure, Output == Downstream.Input {
        dataPublisher.subscribe(subscriber)
    }
}


