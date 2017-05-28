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
    
//    struct pinnotation {
//        var pin: Pin
//        var annotation: MKAnnotation
//    }
    
    var selectedPin: MKAnnotation?
    
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
        
        let pin = Pin(lat: coordinate.latitude, long: coordinate.longitude, context: DBController.context())
        
        pin.annotation = annotation
        
        mapView.addAnnotation(annotation)
        
        DBController.save()
        
        fetchPhotos(pin: pin)
        
    }
    
    func fetchPhotos(pin: Pin) {
        
        let methodParameters = [
            FlickrAPI.Constants.Keys.Method : FlickrAPI.Constants.Values.SearchMethod,
            FlickrAPI.Constants.Keys.APIKey : FlickrAPI.Constants.Values.APIKey,
            FlickrAPI.Constants.Keys.SafeSearch : FlickrAPI.Constants.Values.UseSafeSearch,
            FlickrAPI.Constants.Keys.BoundingBox: bboxString(latitude: pin.pinLatitude, longitude: pin.pinLongtitude),
            FlickrAPI.Constants.Keys.Extras : FlickrAPI.Constants.Values.MediumURL,
            FlickrAPI.Constants.Keys.Format : FlickrAPI.Constants.Values.ResponseFormat,
            FlickrAPI.Constants.Keys.NoJSONCallback : FlickrAPI.Constants.Values.DisableJSONCallback
        ]
        
        FlickrAPI.shared.getPhotosForLocation(methodParameters as [String : AnyObject]) { (photos) in
            
            for photo in photos {
                
                // if an image exists at the url, create a photo in DB
                let imageURL = URL(string: photo)
                if let imageData = try? Data(contentsOf: imageURL!) {
                    let newPhoto = Photo(image: imageData, context: DBController.context())
                    newPhoto.addToPin(pin)
                    
                } else {
                    print("Couldn't deciper image data, skipping image")
                }

            }
        }
        
    }
    
    func bboxString(latitude: Double, longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
            let minimumLon = max(longitude - FlickrAPI.Constants.Flickr.SearchBBoxHalfWidth, FlickrAPI.Constants.Flickr.SearchLonRange.0)
            let minimumLat = max(latitude - FlickrAPI.Constants.Flickr.SearchBBoxHalfHeight, FlickrAPI.Constants.Flickr.SearchLatRange.0)
            let maximumLon = min(longitude + FlickrAPI.Constants.Flickr.SearchBBoxHalfWidth, FlickrAPI.Constants.Flickr.SearchLonRange.1)
            let maximumLat = min(latitude + FlickrAPI.Constants.Flickr.SearchBBoxHalfHeight, FlickrAPI.Constants.Flickr.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedPin = view.annotation
        performSegue(withIdentifier: "showPin", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let pinView = segue.destination as? PinViewController
        pinView?.annotation = selectedPin
        present(pinView!, animated: true, completion: nil)
    }

}
