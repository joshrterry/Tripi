//
//  Persistence.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-06-12.
//

import CoreData
import CoreLocation
import SwiftUI

struct PersistenceController {
    static var shared = PersistenceController()

    let container: NSPersistentCloudKitContainer
    var newTrip: Trip? = nil

    // initialize cloudkit container with name "LocationTracker"
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "LocationTracker")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            // handle any errors when creating persistent store
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    // method for adding user generated tags to database
    func addTag(name: String, colour: [Double], reimbursementAmount: Double) {
        let newTag = UserTag(context: container.viewContext)
        newTag.dateCreated = Date()
        newTag.name = name
        newTag.reimbursementAmount = reimbursementAmount
        
        // ensure that colour array contains exactly 3 values. if not, provide a default array
        if colour.count == 3 {
            newTag.colour = [colour[0], colour [1], colour[2]]
        } else {
            newTag.colour = [0, 0, 0]
        }
        save()
    }
    
    // method for adding a new trip to database. returns a trip that can be edited later
    mutating func addTrip(startTime: Date) -> Trip {
        print("Trip Created")
        newTrip = Trip(context: container.viewContext)
        newTrip!.startTimestamp = startTime
        newTrip!.id = UUID()
        newTrip!.region = [0.0, 0.0, 0.0, 0.0]

        save()
        return newTrip ?? Trip(context: container.viewContext)
    }
    
    // method for writing new data to the trip object once the user has finished their route
    mutating func editTrip(trip: Trip, distance: Double, time: String, speed: Double, startTime: Date, endTime: Date, seconds: Double) {
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
        
        // find maximum and minumum coordinate values to determine an appropriate center point for the map
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
    
        // average out values and store in region array
        trip.region = [0.0, 0.0, 0.0, 0.0]
        trip.region[0] = (minLat + maxLat) / 2
        trip.region[1] = (minLon + maxLon) / 2
        
        // determine an appropriate zoom level by finding the difference between max and min
        trip.region[2] = (maxLat - minLat) * 1.4
        trip.region[3] = (maxLon - minLon) * 1.4
    
        // if more than 5 waypoints in array, we have enough to graph the speed of the trip
        if trip.locationsArray.count >= 5 {
            var speedsOnly: [Double] = []
            // split locationsArray into approximately 5 even segments
            let splitData = trip.locationsArray.chunked(into: Int(trip.locationsArray.count/5))
            
            // extract speed value from waypoints
            for element in splitData {
                speedsOnly = []
                for value in element {
                    speedsOnly.append(value.speed)
                }
                
                // append data to database
                trip.graphedSpeedsY.append(speedsOnly.reduce(0, +)/Double(speedsOnly.count))
                trip.graphedSpeedsX.append(element[0].timestamp ?? Date())
            }
        }

        save()

    }
        
    // method for adding location waypoints
    func addLocation(location: (longitude: Double, latitude: Double, speed: Double, trip: Trip)) {
        let newLocation = Location(context: container.viewContext)
        newLocation.timestamp = Date()
        newLocation.longitude = location.longitude
        newLocation.latitude = location.latitude
        newLocation.speed = location.speed
        newLocation.trip = location.trip
        save()
    }
    
    // method for deleting trip passed as argument
    func delete(trip: Trip) {
        let context = container.viewContext
        context.delete(trip)
        save()
    }
    
    // method for deleting tag passed as argument
    func deleteTag(tag: UserTag) {
        let context = container.viewContext
        context.delete(tag)
        save()
    }
    
    // method to save all changes in the current view context
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            // catch errors thrown from saving and return error message
            do {
                try context.save()
            } catch {
                fatalError("Unable to save data.")
            }
        }
    }
}
