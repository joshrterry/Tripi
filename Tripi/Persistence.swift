//
//  Persistence.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-06-12.
//

import CoreData

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
    
    mutating func addTrip(distance: Double, time: String, speed: Double, startTime: Date, endTime: Date, seconds: Double) {
        newTrip = Trip(context: container.viewContext)
        newTrip!.expenseTag = "business"
        newTrip!.distance = distance
        newTrip!.startTimestamp = startTime
//        newTrip!.startTimestamp = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())
        newTrip!.endTimestamp = endTime
        newTrip!.time = time
        newTrip!.secondsElapsed = seconds
        print(newTrip!.secondsElapsed)
        newTrip!.averageSpeed = speed
        newTrip!.id = UUID()
        save()
    }
    
    func add(location: (longitude: Double, latitude: Double)) {
        let newLocation = Location(context: container.viewContext)
        newLocation.timestamp = Date()
        newLocation.longitude = location.longitude
        newLocation.latitude = location.latitude
        if newTrip != nil {
            newLocation.trip = newTrip
        }
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
