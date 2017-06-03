//
//  PinViewController.swift
//  Virtual Tourist
//
//  Created by Jay Mutzafi on 5/27/17.
//  Copyright © 2017 Paradox Apps. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PinViewController: UIViewController, UICollectionViewDelegate {
    
    var annotation: PinAnnotation?
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.addAnnotation(annotation!)
            
            mapView.setCenter(annotation!.coordinate, animated: true)
            
            let span = MKCoordinateSpanMake(0.5, 0.5)
            
            let region = MKCoordinateRegion(center: annotation!.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "pinLatitude == %@", (annotation!.pin.pinLatitude))
        
        do{
            let searchResults = try DBController.context().fetch(fetchRequest)
            print("number of results: \(searchResults.count)")
            
            for result in searchResults as [Pin] {
                
                if result.pinLongtitude == annotation?.coordinate.longitude {
//                    result.photo
                }
            }
        }
        catch{
            print("Error: \(error)")
        }
        
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
//        cell.image =
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */


}
