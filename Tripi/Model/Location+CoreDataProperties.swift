//
//  Location+CoreDataProperties.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-10-02.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var speed: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var timestamp: Date?
    @NSManaged public var trip: Trip?

    public var wrappedLatitude: Double {
        latitude
    }
    
    public var wrappedLongitude: Double {
        longitude
    }
    
    public var wrappedTimestamp: Date {
        timestamp ?? Date()
    }
    
}

extension Location : Identifiable {

}
