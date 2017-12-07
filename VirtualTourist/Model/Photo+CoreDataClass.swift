//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by RYAN ROSELLO on 11/15/17.
//  Copyright © 2017 RYAN ROSELLO. All rights reserved.
//
//

import Foundation
import CoreData


public class Photo: NSManagedObject {
    
    
    convenience init(id: String, context: NSManagedObjectContext) {
        
        if let description = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            
            self.init(entity: description, insertInto: context)

            self.id = id
            self.imageData = nil
        }
        else {
            fatalError("Unable to find entity description Photo in initializer")
        }
    }

}
