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
        
        loadMapSettings()
        
        if let pins = DBController.loadExistingPins() {
            for pin in pins {
                let annotation = PinAnnotation(pin: pin)
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    func loadMapSettings() {
        if UserDefaults.standard.bool(forKey: "isFirstRun") {
            
        } else {
            
            // Load last map center and zoom level
            
            let lat = UserDefaults.standard.double(forKey: "mapCenterLat")
            let long = UserDefaults.standard.double(forKey: "mapCenterLong")
            let spanLat = UserDefaults.standard.double(forKey: "mapSpanLat")
            let spanLong = UserDefaults.standard.double(forKey: "mapSpanLong")
            
            let span = MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLong)
            let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: false)
        }
    }
    
    @IBAction func addPinTap(_ sender: UILongPressGestureRecognizer) {
        
        // create a pin object at this location
        
        if sender.state == UIGestureRecognizerState.ended {
            let location = sender.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            let pin = Pin(lat: coordinate.latitude, long: coordinate.longitude, context: DBController.context())
            
            let pinnotation = PinAnnotation(pin: pin)
            
            // add pin to map
            
            mapView.addAnnotation(pinnotation)
            
            DBController.save()
            
            // fetch photos
            
            DBController.fetchPhotos(pin: pin) {
                DBController.save()
            }
        }
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let lat = mapView.region.center.latitude
        let long = mapView.region.center.longitude
        let spanLat = mapView.region.span.latitudeDelta
        let spanLong = mapView.region.span.longitudeDelta
        let mapRegionValues = [
            "mapCenterLat" : lat,
            "mapCenterLong" : long,
            "mapSpanLat" : spanLat,
            "mapSpanLong" : spanLong
        ]
        UserDefaults.standard.setValuesForKeys(mapRegionValues)
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
