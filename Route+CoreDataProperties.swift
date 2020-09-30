//
//  Route+CoreDataProperties.swift
//  Holo
//
//  Created by Stanislav Slipchenko on 30.09.2020.
//
//

import Foundation
import CoreData


extension Route {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Route> {
        return NSFetchRequest<Route>(entityName: "Route")
    }

    @NSManaged public var routeLength: Double
    @NSManaged public var time: String?
    @NSManaged public var coordinates: NSSet?

}

// MARK: Generated accessors for coordinates
extension Route {

    @objc(addCoordinatesObject:)
    @NSManaged public func addToCoordinates(_ value: CoordinatesCoreData)

    @objc(removeCoordinatesObject:)
    @NSManaged public func removeFromCoordinates(_ value: CoordinatesCoreData)

    @objc(addCoordinates:)
    @NSManaged public func addToCoordinates(_ values: NSSet)

    @objc(removeCoordinates:)
    @NSManaged public func removeFromCoordinates(_ values: NSSet)

}

extension Route : Identifiable {

}
