//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Jay Mutzafi on 5/25/17.
//  Copyright © 2017 Paradox Apps. All rights reserved.
//

import Foundation
import CoreData

extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var pin: Pin?

}

// MARK: Generated accessors for photo
extension Photo {
    
    @objc(addPinObject:)
    @NSManaged public func addToPin(_ value: Pin)
    
    @objc(removePinObject:)
    @NSManaged public func removeFromPin(_ value: Pin)
    
    @objc(addPin:)
    @NSManaged public func addToPin(_ values: NSSet)
    
    @objc(removePin:)
    @NSManaged public func removeFromPin(_ values: NSSet)
    
}
