//
//  Photo+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Jay Mutzafi on 5/25/17.
//  Copyright © 2017 Paradox Apps. All rights reserved.
//

import UIKit
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {

    convenience init(image: Data, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.imageData = image as NSData
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
