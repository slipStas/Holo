//
//  CoordinatesCoreData+CoreDataProperties.swift
//  Holo
//
//  Created by Stanislav Slipchenko on 28.09.2020.
//
//

import Foundation
import CoreData


extension CoordinatesCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoordinatesCoreData> {
        return NSFetchRequest<CoordinatesCoreData>(entityName: "CoordinatesCoreData")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var route: Route?

}

extension CoordinatesCoreData : Identifiable {

}