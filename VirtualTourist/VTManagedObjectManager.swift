import UIKit
import CoreData

class VTManagedObjectManager: NSObject {
    
    static let shared = VTManagedObjectManager()
    
    func getPhotosForPin(pin: Pin, fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>, completionHandler: @escaping(_: Bool, _: String?) -> Void) {
     
        VTAPIClient.shared.getPhotoDictionariesForCoordinates(lat: pin.latitude, lon: pin.longitude) { [unowned self] (resultsArray, errorString) in
            
            if let errorString = errorString {
        
                print("Error in getPhotoDictionariesForCoordinates called in getPhotosForPin in VTMOM")
                print("error: \(errorString)")
                completionHandler(false, errorString)
            }
            else if let results = resultsArray {
                
                print("results: \(results)")
                
                // 1. Get image data with unique id number. Method also calls for image data for each new managed photo object
                self.createPhotoObjectsFromFlickrResponseArrayOfDictionaries(array: results, pin: pin, fetchedResultsController: fetchedResultsController)
                completionHandler(true, nil)
            }
            else {
                fatalError("Should never get here In VTMOM")
            }
        }
    }
    
    func createPhotoObjectsFromFlickrResponseArrayOfDictionaries(array: Array<Any>, pin: Pin, fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>) -> Void {
        
        for case let dict as Dictionary<String, Any> in array {
            
            if let id = dict["id"] as? String {
                
                // Create new managed photo objects with nil image data
                let newManagedPhoto = Photo.init(id: id, context: fetchedResultsController.managedObjectContext)
                newManagedPhoto.pin = pin
                
                
                // Call for image data
                if let urlString = dict["url_m"] as? String, let url = URL(string: urlString) {
                    
                    print("calling for image data for id: \(id)")
                    
                    
                    VTAPIClient.shared.getImageWithIdForUrl(url: url, id: id, completionHandler: { [unowned self] (image, id) in
                        
                        if image == nil {
                            // TODO: Anything to do if no image? Leave placedholder or remove photo object?
                        }
                        else {
                            
                            print("SAVING for image data for id: \(id)")
                            self.saveImageDataToManagedPhotoObject(image: image!, id: id, fetchedResultsController: fetchedResultsController)
                        }
                    })
                }
            }
        }
    }
    
    
    func saveImageDataToManagedPhotoObject(image: UIImage, id: String, fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>) {
        
        if let photos = fetchedResultsController.fetchedObjects {
            
            for case let photo as Photo in photos {
                
                if photo.id == id {
                    
                    if let data = UIImageJPEGRepresentation(image, 1.0) {
                    
                        photo.imageData = NSData(data: data)
                    }
                }
            }
        }
    }
    
    func refreshPhotosForPin(pin: Pin, fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>, completionHandler: @escaping(_: Bool, _: String?) -> Void) {
        
        for case let photo as Photo in pin.photos! {
            fetchedResultsController.managedObjectContext.delete(photo)
        }
        
        do {
            try fetchedResultsController.managedObjectContext.save()
            completionHandler(true, nil)
        }
        catch {
            print(error.localizedDescription)
            completionHandler(false, error.localizedDescription)
        }
        
        // TODO: Call for more photos
    }
    
    func removePhoto(photo: Photo, fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>, completionHandler: (_: Bool, _: String?) -> Void) {
        
        print("Implement remove photo method")
        
        fetchedResultsController.managedObjectContext.delete(photo)
        
        do {
            try fetchedResultsController.managedObjectContext.save()
            completionHandler(true, nil)
        }
        catch {
            print(error.localizedDescription)
            completionHandler(false, error.localizedDescription)
        }
    }

}
