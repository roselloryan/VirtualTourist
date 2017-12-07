import UIKit
import MapKit

class VTPin: NSObject, MKAnnotation {

    // Enables keyValue observing, so the pin moves on the map moves when new coordinate is set. Learn this
    dynamic var coordinate: CLLocationCoordinate2D
    
//    var coordinate: CLLocationCoordinate2D {
//        willSet {
//            willChangeValue(for: \.coordinate)
//        }
//        didSet {
//            didChangeValue(for: \.coordinate)
//        }
//    }
    
    init(coordinate: CLLocationCoordinate2D) {
        
        self.coordinate = coordinate
        
        super.init()
    }
}

