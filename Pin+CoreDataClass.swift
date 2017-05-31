//
//  Pin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Jay Mutzafi on 5/30/17.
//  Copyright © 2017 Paradox Apps. All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(Pin)
public class Pin: NSManagedObject {
    
    convenience init(lat: Double, long: Double, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.pinLatitude = lat
            self.pinLongtitude = long
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
}
