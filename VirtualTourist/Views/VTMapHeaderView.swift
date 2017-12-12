import UIKit
import MapKit

class VTMapHeaderView: UICollectionReusableView {
        
    @IBOutlet weak var mapView: MKMapView!
    
    var pin: Pin! {
        
        didSet {
            
            mapView.delegate = self
            mapView.addAnnotation(pin)
            mapView.region.center = pin.coordinate
            mapView.isUserInteractionEnabled = false
            mapView.region.span = MKCoordinateSpan.init(latitudeDelta: 5.0, longitudeDelta: 5.0)
        }
    }
}

extension VTMapHeaderView: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var view: MKPinAnnotationView
        
        guard let annotation = annotation as? Pin else {
            return nil
        }
        
        if let deqeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.Indentifier.PinReuseId) as? MKPinAnnotationView {
            deqeuedView.annotation = annotation
            view = deqeuedView
        }
        else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.Indentifier.PinReuseId)
            view.canShowCallout = false
        }
        
        return view
    }
}
