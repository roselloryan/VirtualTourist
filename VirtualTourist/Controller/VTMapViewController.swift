import UIKit
import MapKit
import CoreData


class VTMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    var pinJustAdded: Pin?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set delegates
        mapView.delegate = self
        panGestureRecognizer.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        // NAv bar
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationItem.rightBarButtonItem = nil
        
        mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: false)
        
        fetchPins()
    }
    
    func fetchPins() {
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.stack.context
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.Indentifier.Pin)
            
            do {
                let fetchedPins = try context.fetch(fetchRequest) as! [Pin]
                
                if mapView.annotations.count != fetchedPins.count {
                    
                    mapView.removeAnnotations(mapView.annotations)
                    
                    mapView.addAnnotations(fetchedPins)
                }
            }
            catch {
                print("Failed to fetch pins in map controller")
                presentAlertWith(title: "Failed to fetch pins in map controller", message: "")
            }
        }
    }

    // MARK: - Actions
    @IBAction func longPressGestureRecognized(_ sender: UILongPressGestureRecognizer) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        if sender.state == .began {
            print("Recognized long press")
            
            let touchLocation = sender.location(in: mapView)
            let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)


            let newPin = Pin.init(lat: locationCoordinate.latitude, lon: locationCoordinate.longitude, context: appDelegate.stack.context)
            
            mapView.addAnnotation(newPin)
            pinJustAdded = newPin
        }
        else if sender.state == .ended {
            print("Long press ended")
            
            // Save to managed object context
            do {
                try appDelegate.stack.saveContext()
            }
            catch {
                print(error.localizedDescription)
                presentAlertWith(title: "Error saving in map controller" , message: "")
                print("Error saving in map controller")
            }
            
            pinJustAdded = nil
        }
        
    }
    
    @IBAction func panGestureRecognized(_ sender: UIPanGestureRecognizer) {
        
        if let pin = pinJustAdded {
            let touchLocation = sender.location(in: mapView)
            let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            pin.coordinate = locationCoordinate
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let photosVC = segue.destination as? VTCoreDataCollectionViewController {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
            fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "urlString", ascending: false)]
            
            print("mapView.selectedAnnotations.count = \(mapView.selectedAnnotations)")
            
            let pin = mapView.selectedAnnotations[0] as! Pin
            
            let predicate = NSPredicate.init(format: "pin = %@", argumentArray: [pin])
            fetchRequest.predicate = predicate
            
            let stack = (UIApplication.shared.delegate as! AppDelegate).stack
            
            let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
            
            photosVC.pin = pin
            photosVC.fetchedResultsController = fetchedResultsController
        }
        navigationController?.navigationBar.isHidden = false
    }

}

extension VTMapViewController: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        performSegue(withIdentifier: Constants.Indentifier.CollectionViewSegue, sender: nil)
    }
    
    
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
            
            view.animatesDrop = true
            
            view.canShowCallout = false
        }
        
        return view
    }
    
}

extension VTMapViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}






