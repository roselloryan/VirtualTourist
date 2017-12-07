import UIKit

private let reuseIdentifier = "VTCollectionCell"

class VTCoreDataCollectionViewController: CoreDataCollectionViewController {
    
    var pin: Pin!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Photos"
        
        navigationController?.navigationBar.isHidden = false
        
        // Add refresh button
        let refreshButton = UIBarButtonItem.init(barButtonSystemItem: .refresh, target: self, action: #selector(refreshPhotos))
        
        self.navigationItem.rightBarButtonItem = refreshButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if fetchedResultsController?.fetchedObjects?.count == 0 {
            
            // No saved images. Must call Flickr api
            
            dimScreenWithActivitySpinner()
        
            VTManagedObjectManager.shared.getPhotosForPin(pin: pin, fetchedResultsController: fetchedResultsController!, completionHandler: { [unowned self] (success, errorString) in
                
                self.undimScreenAndRemoveActivitySpinner()
                
                if !success {
                    if let errorString = errorString {
                        self.presentAlertWith(title: "Error:", message: errorString)
                    }
                }
            })
        }
    }
    
    
    // MARK: - Button Method
    @objc func refreshPhotos() {
        print("Implement refresh photos method")
        
        VTManagedObjectManager.shared.refreshPhotosForPin(pin: pin, fetchedResultsController: fetchedResultsController!) { [unowned self] (success, errorString) in
            
            if !success {
                if let errorString = errorString {
                    self.presentAlertWith(title: "Error:", message: errorString)
                }
            }
        }
        
    }

   
    // MARK: - UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! VTCollectionViewCell
        
        let photo = fetchedResultsController?.object(at: indexPath) as! Photo
        
        
        cell.imageView.image = photo.imageData == nil ? UIImage.init(named: "placeholder") : UIImage.init(data: photo.imageData! as Data)
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photo = fetchedResultsController?.object(at: indexPath) as! Photo

        VTManagedObjectManager.shared.removePhoto(photo: photo, fetchedResultsController: fetchedResultsController!) { [unowned self] (success, errorString) in
            
            if let errorString = errorString, !success {
                self.presentAlertWith(title: errorString, message: "")
            }
        }
        
    }
    

}




