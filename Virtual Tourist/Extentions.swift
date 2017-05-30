//
//  Extentions.swift
//  Virtual Tourist
//
//  Created by Jay Mutzafi on 5/29/17.
//  Copyright © 2017 Paradox Apps. All rights reserved.
//

import Foundation

//extension Double {
//    /// Rounds the double to decimal places value
//    func roundTo(places:Int) -> Double {
//        let divisor = pow(10.0, Double(places))
//        return (self * divisor).rounded() / divisor
//    }
//}
//
//extension Double
//{
//    func roundTo(places : Int)-> Double
//    {
//        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
//    }
//}

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
