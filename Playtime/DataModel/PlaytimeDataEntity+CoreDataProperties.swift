//
//  PlaytimeDataEntity+CoreDataProperties.swift
//  Playtime
//
//  Created by Nico Christian on 05/05/21.
//
//

import Foundation
import CoreData


extension PlaytimeDataEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlaytimeDataEntity> {
        return NSFetchRequest<PlaytimeDataEntity>(entityName: "PlaytimeDataEntity")
    }

    @NSManaged public var datePlayed: Date?
    @NSManaged public var duration: Double
    @NSManaged public var limit: Double
    @NSManaged public var entryFrom: String

}

extension PlaytimeDataEntity : Identifiable {

}
