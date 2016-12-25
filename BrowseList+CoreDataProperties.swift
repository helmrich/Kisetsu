//
//  BrowseList+CoreDataProperties.swift
//  AniManager
//
//  Created by Tobias Helmrich on 25.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation
import CoreData


extension BrowseList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BrowseList> {
        return NSFetchRequest<BrowseList>(entityName: "BrowseList");
    }

    @NSManaged public var basicSeries: NSOrderedSet?

}

// MARK: Generated accessors for basicSeries
extension BrowseList {

    @objc(insertObject:inBasicSeriesAtIndex:)
    @NSManaged public func insertIntoBasicSeries(_ value: BasicSeries, at idx: Int)

    @objc(removeObjectFromBasicSeriesAtIndex:)
    @NSManaged public func removeFromBasicSeries(at idx: Int)

    @objc(insertBasicSeries:atIndexes:)
    @NSManaged public func insertIntoBasicSeries(_ values: [BasicSeries], at indexes: NSIndexSet)

    @objc(removeBasicSeriesAtIndexes:)
    @NSManaged public func removeFromBasicSeries(at indexes: NSIndexSet)

    @objc(replaceObjectInBasicSeriesAtIndex:withObject:)
    @NSManaged public func replaceBasicSeries(at idx: Int, with value: BasicSeries)

    @objc(replaceBasicSeriesAtIndexes:withBasicSeries:)
    @NSManaged public func replaceBasicSeries(at indexes: NSIndexSet, with values: [BasicSeries])

    @objc(addBasicSeriesObject:)
    @NSManaged public func addToBasicSeries(_ value: BasicSeries)

    @objc(removeBasicSeriesObject:)
    @NSManaged public func removeFromBasicSeries(_ value: BasicSeries)

    @objc(addBasicSeries:)
    @NSManaged public func addToBasicSeries(_ values: NSOrderedSet)

    @objc(removeBasicSeries:)
    @NSManaged public func removeFromBasicSeries(_ values: NSOrderedSet)

}
