//
//  Pin.swift
//  virtualTourist
//
//  Created by Guilherme Carvalho on 12/27/15.
//  Copyright © 2015 Guilherme Carvalho. All rights reserved.
//


import UIKit
import CoreData

@objc(Pin)

class Pin : NSManagedObject {
    
        struct Keys {
            static let Photos = "photos"
            static let Longitude = "lon"
            static let Latitude = "lat"
        }
        
        // 4. We are promoting these four from simple properties, to Core Data attributes
        @NSManaged var lon: NSNumber
        @NSManaged var lat: NSNumber
        @NSManaged var photos: [Photo]
        
        // 5. Include this standard Core Data init method.
        override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
            super.init(entity: entity, insertIntoManagedObjectContext: context)
        }
        
        /**
         * 6. The two argument init method
         *
         * The Two argument Init method. The method has two goals:
         *  - insert the new Pin into a Core Data Managed Object Context
         *  - initialze the Pin's properties from a dictionary
         */
        
        init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
            
            // Get the entity associated with the "Person" type.  This is an object that contains
            // the information from the Model.xcdatamodeld file. We will talk about this file in
            // Lesson 4.
            let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
            
            // Now we can call an init method that we have inherited from NSManagedObject. Remember that
            // the Person class is a subclass of NSManagedObject. This inherited init method does the
            // work of "inserting" our object into the context that was passed in as a parameter
            super.init(entity: entity,insertIntoManagedObjectContext: context)
            
            // After the Core Data work has been taken care of we can init the properties from the
            // dictionary. This works in the same way that it did before we started on Core Data
            lon = dictionary[Keys.Latitude] as! Double
            lat = dictionary[Keys.Longitude] as! Double
        }
}


