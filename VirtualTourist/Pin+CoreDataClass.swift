//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Dean Copeland on 5/2/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation


public class Pin: NSManagedObject {
    // MARK: Initializer
    
    convenience init(latitude: Float, longitude: Float, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("Unable to find Pin Entity name!")
        }
    }
}
