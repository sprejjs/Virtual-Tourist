//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Jay Mutzafi on 5/25/17.
//  Copyright © 2017 Paradox Apps. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var selectedPin: PinAnnotation?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        if let pins = DBController.loadPins() {
            for pin in pins {
                let annotation = PinAnnotation(pin: pin)
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    @IBAction func addPinTap(_ sender: UILongPressGestureRecognizer) {
        
        let location = sender.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        let pin = Pin(lat: coordinate.latitude, long: coordinate.longitude, context: DBController.context())
        
        let pinnotation = PinAnnotation(pin: pin)
        
        mapView.addAnnotation(pinnotation)
        
        DBController.save()
        
        DBController.fetchPhotos(pin: pin) { }
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedPin = view.annotation as? PinAnnotation
        performSegue(withIdentifier: "showPinView", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let pinView = segue.destination as! PinViewController
        pinView.annotation = selectedPin
    }
    
}
