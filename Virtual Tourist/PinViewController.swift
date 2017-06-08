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
        
        collectionView.allowsMultipleSelection = true
        
        newCollectionButton.isEnabled = false
        
        loadLocationPhotos()
        
        if photos.count == 0 {
            
            label.text = "No Photos"
            let width: CGFloat = 80
            let height: CGFloat = 30
            label.frame = CGRect(x: view.bounds.midX - (width / 2), y: view.bounds.midY - (height / 2), width: width, height: height)
            view.addSubview(label)
            getNewCollection()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
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
        
        if newCollectionButton.title == "Delete Selected Photos" {
            if let selectedItems = collectionView.indexPathsForSelectedItems {
                for item in selectedItems {
                    photos.remove(at: item.item)
                    collectionView.deleteItems(at: [item])
                    
                }
            }
            newCollectionButton.title = "New Collection"
        
        } else {
        
            // Disable button while loading new collection
            newCollectionButton.isEnabled = false
        
            getNewCollection()
        }
        
    }
    
    func getNewCollection() {
        
        DBController.fetchPhotos(pin: (annotation?.pin)!) {
            if photos.count != 0 {
                photos.removeAll()
            }
            loadLocationPhotos()
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        let image = UIImage(data: photos[indexPath.item].imageData! as Data)
        
        cell.image.image = image
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
     // change button title if any photos are selected
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView.indexPathsForSelectedItems?.count)! > 0 {
            newCollectionButton.title = "Delete Selected Photos"
        }

    }
    
    // change button title if all photos are deselected
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if (collectionView.indexPathsForSelectedItems?.count)! == 0 {
            newCollectionButton.title = "New Collection"
        }
        
    }
    
}
