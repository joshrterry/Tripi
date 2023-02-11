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
    }
    
    func addTag(name: String, colour: [Double], reimbursementAmount: Double) {
        let newTag = UserTag(context: container.viewContext)
        newTag.dateCreated = Date()
        newTag.name = name
        newTag.reimbursementAmount = reimbursementAmount
        if colour.count == 3 {
            newTag.colour = [colour[0], colour [1], colour[2]]
        } else {
            newTag.colour = [0, 0, 0]
        }
        save()
    }
    
    mutating func addTrip(startTime: Date) -> Trip {
        print("Trip Created")
        newTrip = Trip(context: container.viewContext)
        newTrip!.startTimestamp = startTime
        newTrip!.id = UUID()
//        newTrip!.tags.append("business")
        newTrip!.region = [0.0, 0.0, 0.0, 0.0]

        save()
        return newTrip ?? Trip(context: container.viewContext)
    }
    
    // Create trip when press go, then modify at end !!!!!
    
    mutating func editTrip(trip: Trip, distance: Double, time: String, speed: Double, startTime: Date, endTime: Date, seconds: Double) {
//        trip.tags.append("business")
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
        trip.region[2] = (maxLat - minLat) * 1.4
        trip.region[3] = (maxLon - minLon) * 1.4
    
        
        save()

    }
        
    func addLocation(location: (longitude: Double, latitude: Double, speed: Double, trip: Trip)) {
        let newLocation = Location(context: container.viewContext)
        newLocation.timestamp = Date()
        newLocation.longitude = location.longitude
        newLocation.latitude = location.latitude
        newLocation.speed = location.speed
        newLocation.trip = location.trip
        save()
    }
    
    func delete(trip: Trip) {
        let context = container.viewContext
        context.delete(trip)
        save()
    }
    
    func deleteTag(tag: UserTag) {
        let context = container.viewContext
        context.delete(tag)
        save()
    }
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Unable to save data.")
            }
        }
    }
}
