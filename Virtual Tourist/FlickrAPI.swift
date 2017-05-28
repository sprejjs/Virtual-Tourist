//
//  FlickrAPI.swift
//  Virtual Tourist
//
//  Created by Jay Mutzafi on 5/26/17.
//  Copyright © 2017 Paradox Apps. All rights reserved.
//

import UIKit

class FlickrAPI {
    
    static let shared = FlickrAPI()
    
    struct Constants {
        
        // MARK: Flickr
        struct Flickr {
            static let APIScheme = "https"
            static let APIHost = "api.flickr.com"
            static let APIPath = "/services/rest"
            
            static let SearchBBoxHalfWidth = 1.0
            static let SearchBBoxHalfHeight = 1.0
            static let SearchLatRange = (-90.0, 90.0)
            static let SearchLonRange = (-180.0, 180.0)
        }
        
        // MARK: Flickr Parameter Keys
        struct Keys {
            static let Method = "method"
            static let APIKey = "api_key"
            static let GalleryID = "gallery_id"
            static let Extras = "extras"
            static let Format = "format"
            static let NoJSONCallback = "nojsoncallback"
            static let SafeSearch = "safe_search"
            static let Text = "text"
            static let BoundingBox = "bbox"
            static let Page = "page"
        }
        
        // MARK: Flickr Parameter Values
        struct Values {
            static let SearchMethod = "flickr.photos.search"
            static let APIKey = "866929c00b2f885ed9abf5947181a2a9"
            static let ResponseFormat = "json"
            static let DisableJSONCallback = "1" /* 1 means "yes" */
            static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
            static let GalleryID = "5704-72157622566655097"
            static let MediumURL = "url_m"
            static let UseSafeSearch = "1"
        }
        
        // MARK: Flickr Response Keys
        struct ResponseKeys {
            static let Status = "stat"
            static let Photos = "photos"
            static let Photo = "photo"
            static let Title = "title"
            static let MediumURL = "url_m"
            static let Pages = "pages"
            static let Total = "total"
        }
        
        // MARK: Flickr Response Values
        struct ResponseValues {
            static let OKStatus = "ok"
        }
        
    }
    
    // MARK: Flickr API
    
    func getPhotosForLocation(_ methodParameters: [String: AnyObject], completion: @escaping (_ photos: [String]) -> Void) {
        
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                
            }
            
            guard (error == nil) else {
                displayError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[FlickrAPI.Constants.ResponseKeys.Status] as? String, stat == Constants.ResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* Is "photos" key in our result? */
            guard let photosDictionary = parsedResult[FlickrAPI.Constants.ResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find keys '\(FlickrAPI.Constants.ResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* Is "pages" key in the photosDictionary? */
            guard let totalPages = photosDictionary[FlickrAPI.Constants.ResponseKeys.Pages] as? Int else {
                displayError("Cannot find key '\(FlickrAPI.Constants.ResponseKeys.Pages)' in \(photosDictionary)")
                return
            }
            
            // pick a random page!
            let pageLimit = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            self.displayImageFromFlickrBySearch(methodParameters, withPageNumber: randomPage, completion: { (photos) in
                completion(photos)

            })
        }
        
        // start the task!
        task.resume()
    }
    
    func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject], withPageNumber: Int, completion: @escaping (_ photos: [String]) -> Void) {
        
        // add the page to the method's parameters
        var methodParametersWithPageNumber = methodParameters
        methodParametersWithPageNumber[FlickrAPI.Constants.Keys.Page] = withPageNumber as AnyObject?
        
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))

        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[FlickrAPI.Constants.ResponseKeys.Status] as? String, stat == FlickrAPI.Constants.ResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = parsedResult[FlickrAPI.Constants.ResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find key '\(FlickrAPI.Constants.ResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[Constants.ResponseKeys.Photo] as? [[String: AnyObject]] else {
                displayError("Cannot find key '\(Constants.ResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            if photosArray.count == 0 {
                
                displayError("No Photos Found. Search Again.")
                let photos = [String]()
                completion(photos)
                
            } else {
                
                let maxNumberOfPhotos = 30
                var photos = [String]()
                for i in 1...maxNumberOfPhotos {
                    let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                    let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
                    
                    /* GUARD: Does our photo have a key for 'url_m'? */
                    if let imageUrlString = photoDictionary[FlickrAPI.Constants.ResponseKeys.MediumURL] as? String {
                        photos.append(imageUrlString)
                        
                    } else {
                        // skipping to next photo
                    }
                }
                
                completion(photos)
                
            }
        }
        
        // start the task!
        task.resume()
    }
    
    // MARK: Helper for Creating a URL from Parameters
    
    func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
}
