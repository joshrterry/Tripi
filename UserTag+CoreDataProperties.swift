//
//  UserTag+CoreDataProperties.swift
//  Tripi
//
//  Created by Joshua Terry on 2023-02-01.
//
//

import Foundation
import CoreData
import SwiftUI


extension UserTag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserTag> {
        return NSFetchRequest<UserTag>(entityName: "UserTag")
    }

    @NSManaged public var colour: [Double]?
    @NSManaged public var name: String?
    @NSManaged public var reimbursementAmount: Double
    @NSManaged public var dateCreated: Date
    
}

extension UserTag {
    public var wrappedName: String {
        name ?? "Unnamed Tag"
    }

    // colour stored as [r, g, b] in 0-255; falls back to gray if missing or malformed
    public var displayColour: Color {
        guard let colour, colour.count >= 3 else { return .gray }
        return Color(red: colour[0] / 255, green: colour[1] / 255, blue: colour[2] / 255)
    }
}

extension UserTag : Identifiable {

}
