//
//  Extentions.swift
//  Virtual Tourist
//
//  Created by Jay Mutzafi on 5/29/17.
//  Copyright © 2017 Paradox Apps. All rights reserved.
//

import Foundation

extension Double {
    func roundTo() -> Double {
        
//        return ((self * 100000).rounded() / 100000)
        
        let dub = self
        
        let multi = dub * 100000
        
        let round = multi.rounded()
        
        let final = round / 100000
        
        return final
    }
}
