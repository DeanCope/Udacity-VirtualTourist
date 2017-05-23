//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Dean Copeland on 5/5/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

extension FlickrClient {
    
    // MARK: GET Convenience Methods
    // Get a photos for a location (lat/lon)
    func photosForLocation(_ pin: Pin, _ limit: Int?, context: NSManagedObjectContext, completionHandlerForPhotos: @escaping (_ result: [Photo]?, _ error: FlickrClientError?) -> Void) {
        
        /* 1. Specify parameters */
        
        var parameters = [String:AnyObject]()

        parameters[FlickrClient.ParameterKeys.Method] = FlickrClient.Methods.SearchPhotos as AnyObject
        parameters[FlickrClient.ParameterKeys.Format] = FlickrClient.ParameterValues.Json as AnyObject
        parameters[FlickrClient.ParameterKeys.NoJsonCallback] = FlickrClient.ParameterValues.NoJsonCallbackTrue as AnyObject
        parameters[FlickrClient.ParameterKeys.Latitude] = pin.latitude as AnyObject
        parameters[FlickrClient.ParameterKeys.Longitude] = pin.longitude as AnyObject
        parameters[FlickrClient.ParameterKeys.Extras] = FlickrClient.ParameterValues.Extras as AnyObject
        parameters[FlickrClient.ParameterKeys.PerPage] = "10" as AnyObject
        
        /* 2. Make the request */
        let _ = taskForGETMethod(parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            guard (error == nil) else {
                completionHandlerForPhotos(nil, error)
                return
            }
            
            guard
                let jsonPhotos = results?[FlickrClient.JSONResponseKeys.Photos] as? [String:AnyObject],
                let photosArray = jsonPhotos[FlickrClient.JSONResponseKeys.Photo] as? [[String: AnyObject]] else {
                    completionHandlerForPhotos(nil, .parseFailed(detail: FlickrClient.JSONResponseKeys.Photos))
                    return
            }
            
            let photos = Photo.photosFromResults(photosArray, forPin: pin, context: context)
           // print("Got \(photos.count) photos from Flickr")
            completionHandlerForPhotos(photos, nil)
            
        }
    }
    
    func getImageForPhoto(_ photo: Photo?, completionHandlerForGetImage: @escaping (_ result: Data?, _ error: FlickrClientError?) -> Void) {
        
        guard let photo = photo else {
            return
        }
        guard let urlString = photo.url else {
            return
        }
        guard let url = URL(string: urlString) else {
            return
        }
        
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandlerForGetImage(nil, .connectionFailed(method: "GET", errorString: error.localizedDescription))
            } else {
                completionHandlerForGetImage(data, nil)
            }
        }
        task.resume()
        return
    }
}

