import UIKit
import CoreData

class VTManagedObjectManager: NSObject {
    
    static let shared = VTManagedObjectManager()
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack

    
    // MARK: - Methods
    func getPhotosObjectsForPin(pin: Pin, completionHandler: @escaping(_: String?) -> Void) {

        VTAPIClient.shared.getPhotoDictionaryPageForCoordinates(lat: pin.latitude, lon: pin.longitude, page: pin.page) { [unowned self] (resultsArray, errorString) in

            if let errorString = errorString {

                print("Error in getPhotoDictionariesForCoordinates in getPhotosForPin in VTMOM")
                print("error: \(errorString)")
                completionHandler(errorString)
            }
            else if let results = resultsArray {

                print("pin.page = \(pin.page)")

                if results.count < 20 {
                    pin.page = 1
                }
                else {
                    pin.page += 1
                }

                self.createPhotoObjectsFromFlickrResponseArrayOfDictionaries(array: results, pin: pin)

                completionHandler(nil)
            }
            else {
                fatalError("Fatal Error: Should never get here In VTMOM")
            }
        }
    }

    func createPhotoObjectsFromFlickrResponseArrayOfDictionaries(array: Array<Any>, pin: Pin) -> Void {

        for case let dict as Dictionary<String, Any> in array {

            if let urlString = dict["url_m"] as? String, !urlString.isEmpty {

                // Create new managed photo objects with nil image data
                let newManagedPhoto = Photo.init(urlString: urlString, context: stack.context)
                newManagedPhoto.pin = pin
            }
        }
        DispatchQueue.main.async {
            do {
                try self.stack.saveContext()
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }

    func getPhotoDataForPin(pin: Pin, completionHandler: @escaping(_: Bool) -> Void) {

        if let pinPhotos = pin.photos {

            var completedCalls = 0

            for case let photo as Photo in pinPhotos {

                if let urlString = photo.urlString, let url = URL(string: urlString) {

                    VTAPIClient.shared.getImageWithIdForUrl(url: url, completionHandler: { [unowned self] (image, urlString) in

                        if image == nil {
                            
                            print("Found a nil image! What should we do? Erase the model maybe?")
                        }
                        else {
                            
                            self.saveImageDataToManagedPhotoObject(image: image!, urlString: urlString)
                        }

                        completedCalls += 1

                        if completedCalls == pinPhotos.count {
                            
                            completionHandler(true)
                        }
                    })
                }
            }
        }
    }


    func saveImageDataToManagedPhotoObject(image: UIImage, urlString: String) {

        if let data = UIImageJPEGRepresentation(image, 1.0) {

            let fetchRequest = NSFetchRequest<Photo>.init(entityName: "Photo")
            fetchRequest.predicate = NSPredicate.init(format: "urlString = %@", urlString)

            let fetchResults: Array<Photo>!
            do {
                fetchResults = try stack.context.fetch(fetchRequest)
            }
            catch {
                print(error.localizedDescription)
                fatalError("Fetch failed in object manager. What to do?")
            }


            if fetchResults != nil && fetchResults.count > 0 {
                let photo = fetchResults[0]

                print("Setting imageData for image data for id: \(urlString)")
                photo.imageData = NSData(data: data)
            }
        }
        else {
            print("NO DATA FROM UIIMAGE. DOES THIS EVER HAPPEN?")
        }

        DispatchQueue.main.async {
            do {
                try self.stack.saveContext()
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }

    func deletePhotosForPin(pin: Pin, refreshCompletionHandler: @escaping(_: String?) -> Void) {

        for case let photo as Photo in pin.photos! {
            stack.context.delete(photo)
        }

        DispatchQueue.main.async {
            do {
                try self.stack.saveContext()
                refreshCompletionHandler(nil)
            }
            catch {
                print(error.localizedDescription)
                refreshCompletionHandler(error.localizedDescription)
            }
        }
    }

    func removePhoto(photo: Photo, completionHandler: @escaping(_: String?) -> Void) {
        
        stack.context.delete(photo)
        
        DispatchQueue.main.async { [unowned self] in
            do {
                try self.stack.saveContext()
                completionHandler(nil)
            }
            catch {
                print(error.localizedDescription)
                completionHandler(error.localizedDescription)
            }
        }
    }
    
    func deletePinFromContext(pin: Pin, comletionBlock: @escaping(_: String?) -> Void) {
        stack.context.delete(pin)
        
        DispatchQueue.main.async { [unowned self] in
            do {
                try self.stack.saveContext()
                comletionBlock(nil)
            }
            catch {
                print(error.localizedDescription)
                comletionBlock(error.localizedDescription)
            }
        }
    }
}
