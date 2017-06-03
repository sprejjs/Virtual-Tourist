//
//  AnnotationPin.swift
//  Virtual Tourist
//
//  Created by Jay Mutzafi on 5/27/17.
//  Copyright © 2017 Paradox Apps. All rights reserved.
//

import Foundation
import MapKit

class PinAnnotation: NSObject, MKAnnotation {
    
    
    init(pin: Pin) {
        self.pin = pin
    }
    
    
    var coordinate: CLLocationCoordinate2D {
        
        return CLLocationCoordinate2D(
            latitude: pin.pinLatitude,
            longitude: pin.pinLongtitude
        )
    }
    
    var pin: Pin
    
}

//extension MKAnnotation {
//    
//    var pin: Pin
//}
