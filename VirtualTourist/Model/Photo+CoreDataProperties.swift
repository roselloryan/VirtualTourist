//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by RYAN ROSELLO on 12/5/17.
//  Copyright © 2017 RYAN ROSELLO. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var id: String?
    @NSManaged public var imageData: NSData?
    @NSManaged public var pin: Pin?

}
