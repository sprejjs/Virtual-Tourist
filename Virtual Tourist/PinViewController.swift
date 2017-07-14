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
            if label.superview == view {
                DispatchQueue.main.async {
                    self.label.removeFromSuperview()
                }
                
            }

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
        
        if photos.count == 0 {
            
            newCollectionButton.isEnabled = false
            
            loadPhotos()
            
        } else {
            collectionView.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    func loadPhotos() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", (annotation?.pin)!)
        
        if try! DBController.context().count(for: fetchRequest) > 0 {
            do {
                let searchResults = try DBController.context().fetch(fetchRequest)
                
                for result in searchResults as [Photo] {
                    
                    photos.append(result)
                    
                }
            }
            catch {
                print("Error: \(error)")
            }
        } else {
            DispatchQueue.main.async {
                self.markNoPhotos()
            }
            
        }
        
        if newCollectionButton.isEnabled == false {
            newCollectionButton.isEnabled = true
        }
    }
    
    @IBAction func newCollection(_ sender: Any) {
        
        if newCollectionButton.title == "Delete Selected Photos" {
            if let selectedItems = (collectionView.indexPathsForSelectedItems)?.sorted(by: {$0.item > $1.item}) {
                for item in selectedItems {
                    
                    DBController.context().delete(photos[item.item])
                    DBController.save()
                    photos.remove(at: item.item)
                    
                }
                
                collectionView.reloadData()
            }
            newCollectionButton.title = "New Collection"
        
        } else {
        
            // Disable button while loading new collection
            newCollectionButton.isEnabled = false
        
            getNewCollection()
        }
        
    }
    
    func markNoPhotos() {
        label.text = "No Photos"
        let width: CGFloat = 80
        let height: CGFloat = 30
        label.frame = CGRect(x: view.bounds.midX - (width / 2), y: view.bounds.midY - (height / 2), width: width, height: height)
        view.addSubview(label)
        newCollectionButton.isEnabled = true
    }
    
    func getNewCollection() {
        
        if self.photos.count != 0 {
            
            for photo in self.photos {
                DBController.context().delete(photo)
            }
            
            DBController.save()
            self.photos.removeAll()
            collectionView.reloadData()
            
        }
        
        DBController.fetchPhotos(pin: (annotation?.pin)!) { photoUrls in
            
            DispatchQueue.main.async {
                
                for url in photoUrls {
                    
                    let photo = Photo(imageUrl: url, context: DBController.context())
                    self.annotation?.pin.addToPhoto(photo)
                    self.photos.append(photo)
                    self.collectionView.reloadData()
                }
                
                DBController.save()
            
//                self.loadPhotos()
                
            }
            
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        cell.image.image = #imageLiteral(resourceName: "placeholder")
        cell.activityIndicator.hidesWhenStopped = true
        cell.activityIndicator.startAnimating()
        
        if let imageData = photos[indexPath.item].imageData {
            
            let image = UIImage(data: imageData as Data)
            
            cell.image.image = image
            
            cell.activityIndicator.stopAnimating()
            
        } else {
        
            // if an image exists at the url, create a photo in DB
            
            let imageURL = URL(string: self.photos[indexPath.item].imageUrl!)
            if let imageData = try? Data(contentsOf: imageURL!) {
                DispatchQueue.main.async {
                    
                    let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
                    let p1 = NSPredicate(format: "pin == %@", (self.annotation?.pin)!)
                    let p2 = NSPredicate(format: "imageUrl == %@", (self.photos[indexPath.item].imageUrl)!)
                    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])
                    fetchRequest.predicate = predicate
                    
                    if let photos = try? DBController.context().fetch(fetchRequest) {
                        print(Thread.isMainThread)
                        if photos.count > 1 {
                            print("i made a mistake")
                        } else {
                            photos[0].setValue(imageData, forKey: "imageData")
                        }
                    }
                    
                    DBController.save()
                    
                    let image = UIImage(data: imageData as Data)
                    
                    cell.image.image = image
                    
                    cell.activityIndicator.stopAnimating()
                    
                    
                }
                
            } else {
                print("Couldn't deciper image data, skipping image")
            }
            
        }
        
        newCollectionButton.isEnabled = true
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
