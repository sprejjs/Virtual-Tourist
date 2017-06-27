//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Jay Mutzafi on 6/26/17.
//  Copyright © 2017 Paradox Apps. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var imageUrl: String?
    @NSManaged public var pin: Pin?

}
