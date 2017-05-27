//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Jay Mutzafi on 5/25/17.
//  Copyright © 2017 Paradox Apps. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addPinTap(_ sender: UILongPressGestureRecognizer) {
        
        let location = sender.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
    }
    
    func fetchPhotos() {
        
        let methodParameters = [
            FlickrAPI.Constants.Keys.Method: FlickrAPI.Constants.Values.SearchMethod,
            FlickrAPI.Constants.Keys.APIKey: FlickrAPI.Constants.Values.APIKey,
            FlickrAPI.Constants.Keys.SafeSearch: FlickrAPI.Constants.Values.UseSafeSearch,
            FlickrAPI.Constants.Keys.Extras: FlickrAPI.Constants.Values.MediumURL,
            FlickrAPI.Constants.Keys.Format: FlickrAPI.Constants.Values.ResponseFormat,
            FlickrAPI.Constants.Keys.NoJSONCallback: FlickrAPI.Constants.Values.DisableJSONCallback
        ]
        
        FlickrAPI.shared.getPhotosForLocation(methodParameters as [String : AnyObject])
    }

}
