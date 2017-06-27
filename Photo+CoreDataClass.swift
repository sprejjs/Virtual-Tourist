//
//  Photo+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Jay Mutzafi on 6/26/17.
//  Copyright © 2017 Paradox Apps. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {

    convenience init(imageUrl: String, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.imageUrl = imageUrl
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
}
