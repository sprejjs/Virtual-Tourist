//
//  AnnotationPin.swift
//  Virtual Tourist
//
//  Created by Jay Mutzafi on 5/27/17.
//  Copyright © 2017 Paradox Apps. All rights reserved.
//

import MapKit

extension MKPointAnnotation {
    var pin: Pin! {
        get {
            return self.pin
        }
        set(newValue) {
            self.pin = newValue
        }
    }
}
