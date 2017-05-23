//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Dean Copeland on 5/2/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation
import CoreData


public class Photo: NSManagedObject {
    
    //MARK: Initializers
    // construct a Photo from a dictionary
    // This is a failable initializer.  If any of the required properties are not found, then no instance is created.
    convenience init?(dictionary: [String:AnyObject], pin: Pin, context: NSManagedObjectContext) {
        
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            if let id = dictionary[FlickrClient.JSONResponseKeys.Id] as? String,
                let photoURLString = dictionary[FlickrClient.JSONResponseKeys.PhotoURLString] as? String {
                    self.init(entity: ent, insertInto: context)
            
                    self.id = id
                    self.url = photoURLString
                    self.pin = pin
                }
            else {
                return nil
            }
        } else {
            fatalError("Unable to find Entity name!")
        }

    }
    
    static func photosFromResults(_ results: [[String:AnyObject]], forPin: Pin, context: NSManagedObjectContext) -> [Photo] {
        
        var photos = [Photo]()
        
        // iterate through array of dictionaries, each Photo is a dictionary
        for result in results {
            if let photo = Photo(dictionary: result, pin: forPin, context: context) {
                photos.append(photo)
            }
        }
        
        return photos
    }


}
