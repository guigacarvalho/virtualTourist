//
//  Photo.swift
//  virtualTourist
//
//  Created by Guilherme Carvalho on 12/27/15.
//  Copyright © 2015 Guilherme Carvalho. All rights reserved.
//

import UIKit
import CoreData

@objc(Photo)

class Photo : NSManagedObject {
    
    struct Keys {
        static let ID = "id"
        static let imagePath = "url_m"
    }
    
    @NSManaged var id: NSNumber
    @NSManaged var imagePath: String?
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        id = (dictionary[Keys.ID]?.integerValue)!
        imagePath = dictionary[Keys.imagePath] as? String

    }

    var image: UIImage? {
        get {
            return FlickrAPI.Caches.imageCache.imageWithIdentifier(imagePath)
        }
        
        set {
            FlickrAPI.Caches.imageCache.storeImage(newValue, withIdentifier: imagePath!)
        }
    }
}
