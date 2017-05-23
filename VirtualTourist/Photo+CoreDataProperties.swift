//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Dean Copeland on 5/17/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var id: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var url: String?
    @NSManaged public var pin: Pin?

}
