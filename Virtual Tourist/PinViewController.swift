//
//  PinViewController.swift
//  Virtual Tourist
//
//  Created by Jay Mutzafi on 5/27/17.
//  Copyright © 2017 Paradox Apps. All rights reserved.
//

import UIKit
import MapKit

class PinViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    var annotation: MKAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.addAnnotation(annotation!)
        
        mapView.setCenter(annotation!.coordinate, animated: true)
        
        let span = MKCoordinateSpanMake(0.5, 0.5)
        
        let region = MKCoordinateRegion(center: annotation!.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }


}
