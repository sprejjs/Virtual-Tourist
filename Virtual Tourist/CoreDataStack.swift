//
//  CDDB.swift
//
//
//  Created by Fernando Rodríguez Romero on 21/02/16.
//  Copyright © 2016 udacity.com. All rights reserved.
//

import CoreData

// MARK: - DBController

class DBController{
    
    private init(){
        
    }
    
    class func context() -> NSManagedObjectContext {
        return DBController.persistentContainer.viewContext
    }
    
    // MARK: - Core Data stack
    
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Virtual_Tourist")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    class func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    class func fetchPhotos(pin: Pin, completion: () -> Void) {
        
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
            
            let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
            
            // If pin has previous photos, remove them
            if try! context().count(for: fetchRequest) > 0 {
                pin.removeFromPhoto(pin.photo!)
            }
            
            // Add new downloaded photos
            for photo in photos {
                
                // if an image exists at the url, create a photo in DB
                let imageURL = URL(string: photo)
                if let imageData = try? Data(contentsOf: imageURL!) {
                    let photo = Photo(image: imageData, context: DBController.context())
                    pin.addToPhoto(photo)
                    
                } else {
                    print("Couldn't deciper image data, skipping image")
                }
                
            }
            
            
        }
        DBController.save()
        completion()
        
    }
    
    class func bboxString(latitude: Double, longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
        let minimumLon = max(longitude - FlickrAPI.Constants.Flickr.SearchBBoxHalfWidth, FlickrAPI.Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - FlickrAPI.Constants.Flickr.SearchBBoxHalfHeight, FlickrAPI.Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + FlickrAPI.Constants.Flickr.SearchBBoxHalfWidth, FlickrAPI.Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + FlickrAPI.Constants.Flickr.SearchBBoxHalfHeight, FlickrAPI.Constants.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    class func loadExistingPins() -> [Pin]? {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if (try? DBController.context().count(for: fetchRequest) > 0) != nil {
            if let pins = try? DBController.context().fetch(fetchRequest) {
                return pins
            }
        } else {
            return nil
        }
        
        return nil
    }
}
