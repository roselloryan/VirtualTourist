import Foundation
import CoreData
import MapKit
import CoreLocation


public class Pin: NSManagedObject, MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D {
        
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            willChangeValue(for: \.coordinate)
            latitude = newValue.latitude
            longitude = newValue.longitude
            didChangeValue(for: \.coordinate)
        }
    }

    convenience init(lat: Double , lon: Double, context: NSManagedObjectContext) {
        
        if let entityDescription = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            
            self.init(entity: entityDescription, insertInto: context)
            
            self.latitude = lat
            self.longitude = lon
            self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            self.creationDate = Date()
            self.photos = NSSet()
        }
        else {
            fatalError("Unable to find Pin in entity description")
        }
    }
}


