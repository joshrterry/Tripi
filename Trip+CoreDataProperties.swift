//
//  Trip+CoreDataProperties.swift
//  Tripi
//
//  Created by Joshua Terry on 2023-02-01.
//
//

import Foundation
import CoreData


extension Trip {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trip> {
        return NSFetchRequest<Trip>(entityName: "Trip")
    }

    @NSManaged public var amountReimbursable: Double
    @NSManaged public var averageSpeed: Double
    @NSManaged public var distance: Double
    @NSManaged public var endTimestamp: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var notes: String?
    @NSManaged public var region: [Double]
    @NSManaged public var routeWaypoints: [[Double]]
    @NSManaged public var secondsElapsed: Double
    @NSManaged public var startTimestamp: Date?
    @NSManaged public var time: String?
    @NSManaged public var locations: NSSet?
    @NSManaged public var tags: NSOrderedSet?

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

// MARK: Generated accessors for tags
extension Trip {

    @objc(insertObject:inTagsAtIndex:)
    @NSManaged public func insertIntoTags(_ value: UserTag, at idx: Int)

    @objc(removeObjectFromTagsAtIndex:)
    @NSManaged public func removeFromTags(at idx: Int)

    @objc(insertTags:atIndexes:)
    @NSManaged public func insertIntoTags(_ values: [UserTag], at indexes: NSIndexSet)

    @objc(removeTagsAtIndexes:)
    @NSManaged public func removeFromTags(at indexes: NSIndexSet)

    @objc(replaceObjectInTagsAtIndex:withObject:)
    @NSManaged public func replaceTags(at idx: Int, with value: UserTag)

    @objc(replaceTagsAtIndexes:withTags:)
    @NSManaged public func replaceTags(at indexes: NSIndexSet, with values: [UserTag])

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: UserTag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: UserTag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSOrderedSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSOrderedSet)

}

extension Trip : Identifiable {

}
