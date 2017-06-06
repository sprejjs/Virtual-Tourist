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

class PinViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let label = UILabel()
    
    var annotation: PinAnnotation?
    
    private var photos = [Photo]() {
        didSet {
            if label.superview != view {
                label.removeFromSuperview()
            }
            collectionView.reloadData()
            print(Thread.isMainThread)
        }
    }
    
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

    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newCollectionButton.isEnabled = false
        
        loadLocationPhotos()
        
        if photos.count == 0 {
            
            label.text = "No Photos"
            let width: CGFloat = 80
            let height: CGFloat = 30
            label.frame = CGRect(x: view.bounds.midX - (width / 2), y: view.bounds.midY - (height / 2), width: width, height: height)
            view.addSubview(label)
            
        }
        
    }
    
    func loadLocationPhotos() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "pin == %@", (annotation?.pin)!)
        
        do{
            let searchResults = try DBController.context().fetch(fetchRequest)
            print("number of results: \(searchResults.count)")
            
            for result in searchResults as [Photo] {
                
                photos.append(result)
            }
        }
        catch{
            print("Error: \(error)")
        }
        
        if newCollectionButton.isEnabled == false {
            newCollectionButton.isEnabled = true
        }
    }
    
    @IBAction func newCollection(_ sender: Any) {
        
        // Disable button while loading new collection
        newCollectionButton.isEnabled = false
        
        DBController.fetchPhotos(pin: (annotation?.pin)!) {
            if photos.count != 0 {
                photos.removeAll()
            }
            loadLocationPhotos()
        }
        
    }
    
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        let image = UIImage(data: photos[indexPath.item].imageData! as Data)
        
        cell.image.image = image
        
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
