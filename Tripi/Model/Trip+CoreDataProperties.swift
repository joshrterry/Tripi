//
//  Trip+CoreDataProperties.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-10-02.
//
//

import Foundation
import CoreData
import CoreLocation


extension Trip {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trip> {
        return NSFetchRequest<Trip>(entityName: "Trip")
    }

    @NSManaged public var averageSpeed: Double
    @NSManaged public var distance: Double
    @NSManaged public var endTimestamp: Date?
    @NSManaged public var tags: [String]
    @NSManaged public var id: UUID?
    @NSManaged public var secondsElapsed: Double
    @NSManaged public var startTimestamp: Date?
    @NSManaged public var time: String?
    @NSManaged public var locations: NSSet?
    @NSManaged public var routeWaypoints: [[Double]]
    @NSManaged public var region: [Double]
    @NSManaged public var notes: String?

    
    public var locationsArray: [Location] {
        let locations = locations as? Set<Location> ?? []
        return locations.sorted {
            $0.wrappedTimestamp < $1.wrappedTimestamp
        }
    }
}

// MARK: Generated accessors for locations
extension Trip {

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: Location)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: Location)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: NSSet)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: NSSet)

}

extension Trip : Identifiable {

}
