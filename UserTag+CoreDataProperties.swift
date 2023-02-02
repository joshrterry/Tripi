//
//  UserTag+CoreDataProperties.swift
//  Tripi
//
//  Created by Joshua Terry on 2023-02-01.
//
//

import Foundation
import CoreData


extension UserTag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserTag> {
        return NSFetchRequest<UserTag>(entityName: "UserTag")
    }

    @NSManaged public var colour: [Double]?
    @NSManaged public var name: String?
    @NSManaged public var reimbursementAmount: Double
    @NSManaged public var dateCreated: Date
    
}

extension UserTag : Identifiable {

}
