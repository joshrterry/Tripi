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
import CoreMotion


class RouteManager: NSObject, ObservableObject {
    @Published var trackingState: TrackingState = .inactive
    @Published var distanceTotal = 0.0
    @Published var time = "00:00"
    @Published var averageSpeed = 0.0
    @Published var currentSpeed = 0.0
    @Published var routeWaypoints: [CLLocationCoordinate2D] = []
    @Published var startTime = Date()
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    @Published var currentActivity: CMMotionActivity = CMMotionActivity()

    
    var lastTwoLocations = (last: CLLocation(latitude: 0, longitude: 0), current: CLLocation(latitude: 0, longitude: 0))
    
    // creates new instance of Trip
    var newTrip: Trip = Trip()
    
    @Published var secondsElapsed = 0.0
    
    var timerStartTime: Date = Date()
    
    var timer = Timer()
    
    // start a timer to track the duration of the trip
    func startTimer() {
        timerStartTime = Date() // start from the current time
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
    
    // pause timer
    func pauseTimer() {
        timer.invalidate()
    }
    
    // reset timer to 00:00
    func resetTimer() {
        timer.invalidate()
        secondsElapsed = 0
        time = "00:00"
    }
    
    // format seconds to form MM:SS
    public func secondstoMinutesSeconds(seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior  = .pad
        
        // return formatted duration as string
        return formatter.string(from: TimeInterval(seconds))!
    }
    
    // convert seconds to hours
    public func secondstoHours(seconds: Double) -> Double {
        return seconds/3600
    }
    
    private var lastLocation: CLLocation!
    
    public var locationManager: CLLocationManager!
    
    typealias Output = (longitude: Double, latitude: Double, speed: Double, trip: Trip)
    typealias Failure = Never
    
    // initialize passthroughsubject to transmit location data
    private let dataPublisher = PassthroughSubject<(Output), Failure>()
    
    // run locationManagerConfig when RouteManager is initialized
    override init() {
        super.init()
        if hasOnboarded {
            locationManagerConfig()
        }
    }
    
    // request access to location services and initialize location manager
    public func locationManagerConfig() {
        locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    // start route tracking, timer, and motion updates
    public func startRoute() {
        self.locationManager.startUpdatingLocation()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.allowsBackgroundLocationUpdates = true // allows program to function while not open
        self.trackingState = .active
        startMotionUpdates() // monitor activity type for end trip automation
        startTimer() // start timer to monitor trip duration
        startTime = Date()
        newTrip = PersistenceController.shared.addTrip(startTime: startTime) // initialize the newTrip object with startTime variable
        
    }
    
    // end trip tracking, timer, and motion updates
    public func stopRoute() {
        PersistenceController.shared.editTrip(trip: newTrip, distance: distanceTotal, time: time, speed: averageSpeed, startTime: startTime, endTime: Date(), seconds: secondsElapsed) // edit the previously created Trip object to add remaining fields
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.stopUpdatingLocation()
        trackingState = .inactive
        stopMotionUpdates()
        
        // clear variables from last trip
        lastLocation = nil
        distanceTotal = 0
        currentSpeed = 0
        averageSpeed = 0
        routeWaypoints = []
        resetTimer()
    }
    
    // temporarily pause route until it is stopped entirely or resumed
    public func pauseRoute() {
        trackingState = .paused
        pauseTimer()
        stopMotionUpdates()
        lastLocation = nil
        locationManager.stopUpdatingLocation()
    }
    
    // resume route from pause state
    public func resumeRoute() {
        trackingState = .active
        startTimer()
        startMotionUpdates()
        locationManager.startUpdatingLocation()
    }
    
    // toggle between active and inactive route depending on current state
    public func toggleTrip() {
        if trackingState == .inactive {
            startRoute()
        } else {
            stopRoute()
        }
    }
    
    // toggle between paused and active route depending on current state
    public func togglePause() {
        if trackingState == .paused {
            resumeRoute()
        } else {
            pauseRoute()
        }
    }
    
    // gets average speed over the course of the trip
    private func getAvgSpeed() {
        averageSpeed = (distanceTotal)/(secondsElapsed/3600)
    }
    
    // gets current speed to display at bottom of screen in tab bar
    private func getCurrentSpeed() {
        currentSpeed = (lastTwoLocations.current.distance(from: lastTwoLocations.last)/1000)/(lastTwoLocations.current.timestamp.timeIntervalSince(lastTwoLocations.last.timestamp)/3600)
    }
    
    // MARK: Activity Manager
    
    var activityManager: CMMotionActivityManager!
    let notificationManager = NotificationManager()
    @AppStorage("selectedAutonomy") var selectedAutonomy = 0
    
    @Published var recentActivities: [Int] = []
    var activityTimer = Timer()

    
    private func checkIfStopped() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
//            self.notificationManager.promptToEnd()
//        }
        if trackingState == .active {
            activityTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { (_) in
                if self.currentActivity.automotive && self.trackingState == .active {
                    self.recentActivities.append(0)
                } else {
                    self.recentActivities.append(1)
                }
                if self.recentActivities.count > 9 && self.trackingState == .active {
                    self.recentActivities.removeFirst()
                    // calculate the sum of the array
                    let sum = self.recentActivities.reduce(0) { result, number in
                        result + number
                    }
                    // convert to double and divide by the count of the array
                    let average = Double(sum) / Double(self.recentActivities.count)
                    
                    if average >= 1 && self.trackingState == .active {
                        self.recentActivities = []
                        if self.selectedAutonomy == 1 {
                            self.notificationManager.promptToEnd()
                        }
                        else if self.selectedAutonomy == 2 {
                            self.notificationManager.autoStopMessage()
                            self.pauseRoute()
                        }
                    }
                }
                self.checkIfStopped()
            }
        }
    }
    
    
    func startMotionUpdates() {
//        currentActivity = CMMotionActivity()
        // creates a new instance of CMMotionActivityManager
        self.activityManager = CMMotionActivityManager()
        self.recentActivities = []

        // start updating activity data and publishing to applications main thread
        DispatchQueue.main.async {
            self.activityManager.startActivityUpdates(to: .main) { (activity: CMMotionActivity?) in
                guard let activity = activity else { return }
                self.currentActivity = activity
            }
            self.checkIfStopped()

        }



    }
    
    func stopMotionUpdates() {
        self.activityManager.stopActivityUpdates()
        activityTimer.invalidate()
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
