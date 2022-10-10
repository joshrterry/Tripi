//
//  Persistence.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-06-12.
//

import CoreData
import CoreLocation

struct PersistenceController {
    static var shared = PersistenceController()

    let container: NSPersistentCloudKitContainer
    var newTrip: Trip? = nil


    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "LocationTracker")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
//        newTrip = Trip(context: container.viewContext)
    }
    
    mutating func addTrip(startTime: Date) -> Trip {
        print("Trip Created")
        newTrip = Trip(context: container.viewContext)
//        newTrip!.expenseTag = "business"
//        newTrip!.distance = distance
        newTrip!.startTimestamp = startTime
//        newTrip!.endTimestamp = endTime
//        newTrip!.time = time
//        newTrip!.secondsElapsed = seconds
//        newTrip!.averageSpeed = speed
        newTrip!.id = UUID()
        save()
        return newTrip ?? Trip(context: container.viewContext)
    }
    
    // Create trip when press go, then modify at end !!!!!
    
    mutating func editTrip(trip: Trip, distance: Double, time: String, speed: Double, startTime: Date, endTime: Date, seconds: Double) {
        trip.expenseTag = "business"
        trip.distance = distance
        trip.startTimestamp = startTime
        trip.endTimestamp = endTime
        trip.time = time
        trip.secondsElapsed = seconds
        trip.averageSpeed = speed
        
        var minLat = 90.0
        var minLon = 180.0
        var maxLat = -90.0
        var maxLon = -180.0
        
        for location in trip.locationsArray {
            trip.routeWaypoints.append([location.latitude, location.longitude])
            if location.latitude < minLat {
                minLat = location.latitude
            }
            if location.longitude < minLon {
                minLon = location.longitude
            }
            if location.latitude > maxLat {
                maxLat = location.latitude
            }
            if location.longitude > maxLon {
                maxLon = location.longitude
            }
        }
        trip.region = [0.0, 0.0, 0.0, 0.0]
        trip.region[0] = (minLat + maxLat) / 2
        trip.region[1] = (minLon + maxLon) / 2
        trip.region[2] = (maxLat - minLat) * 1.5
        trip.region[3] = (maxLon - minLon) * 1.5
    
        
        save()

    }
    
    
    func add(location: (longitude: Double, latitude: Double, trip: Trip)) {
        let newLocation = Location(context: container.viewContext)
        newLocation.timestamp = Date()
        newLocation.longitude = location.longitude
        newLocation.latitude = location.latitude
        newLocation.trip = location.trip
        save()
    }
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
//                print("Data saved")
            } catch {
                fatalError("Unable to save location.")
            }
        }
    }
}
