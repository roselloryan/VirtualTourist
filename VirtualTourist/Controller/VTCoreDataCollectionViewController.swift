import UIKit
import MapKit

private let reuseIdentifier = "VTCollectionCell"
private let mapHeaderIdentifier = "MapHeaderView"
private let refreshFooterIdentifier = "VTRefreshFooterView"

class VTCoreDataCollectionViewController: CoreDataCollectionViewController {
    
    var pin: Pin!
    var mapView: MKMapView!
    weak var footerView: VTRefreshFooterView?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Photos"
        
        
        navigationController?.navigationBar.isHidden = false
        
        
        let deletePinButton = UIBarButtonItem.init(barButtonSystemItem: .trash, target: self, action: #selector(deletePin))
        self.navigationItem.rightBarButtonItem = deletePinButton
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // If no pin has no images call Flickr API
        if fetchedResultsController?.fetchedObjects?.count == 0 {
            
            dimScreenWithActivitySpinner()
            disableButtons()
        
            VTManagedObjectManager.shared.getPhotosObjectsForPin(pin: pin, completionHandler: { [unowned self] (errorString) in
                
                self.undimScreenAndRemoveActivitySpinner()
                
                if let errorString = errorString {
                    
                    self.enableButtons()
                    self.presentAlertWith(title: "Error:", message: errorString)
                }
                else {
                    
                    VTManagedObjectManager.shared.getPhotoDataForPin(pin: self.pin, completionHandler: { (completedCalls) in
                        
                        if completedCalls {
                            
                            self.enableButtons()
                        }
                        else {
                            fatalError("We should never get here.")
                        }
                    })
                }
            })
        }
    }
    
    
    // MARK: - Button Method
    
    @objc func deletePin() {

        dimScreenWithActivitySpinner()
        disableButtons()
        
        VTManagedObjectManager.shared.deletePinFromContext(pin: pin) { [unowned self] (errorString) in
            
            self.undimScreenAndRemoveActivitySpinner()
            self.enableButtons()
            
            if let errorString = errorString {
                
                self.presentAlertWith(title: errorString, message: "")
            }
            else {
                
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    @objc func refreshPhotos() {
        print("Refresh tapped")
        
        dimScreenWithActivitySpinner()
        disableButtons()
        
        VTManagedObjectManager.shared.deletePhotosForPin(pin: pin) { [unowned self] (errorString) in
        
            if let errorString = errorString {
                
                self.undimScreenAndRemoveActivitySpinner()
                
                self.presentAlertWith(title: errorString, message: "")
            }
            
            else {
            
                VTManagedObjectManager.shared.getPhotosObjectsForPin(pin: self.pin, completionHandler: { (errorString) in
                
                    self.undimScreenAndRemoveActivitySpinner()
                
                    if let errorString = errorString {
                    
                        self.enableButtons()
                        self.presentAlertWith(title: errorString, message: "")
                    }
                    else {
                    
                        VTManagedObjectManager.shared.getPhotoDataForPin(pin: self.pin, completionHandler: { (completedCalls) in
                        
                            if completedCalls {
                                self.enableButtons()
                            }
                            else {
                                print("WHY IS THIS FALSE")
                            }
                        })
                    }
                })
            }
        }
    }
    
    func disableButtons() {
        DispatchQueue.main.async { [unowned self] in
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            
            self.footerView?.refreshButton.isEnabled = false
        }
        
    }
    
    func enableButtons() {
        DispatchQueue.main.async { [unowned self] in
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            
            self.footerView?.refreshButton.isEnabled = true
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

        VTManagedObjectManager.shared.removePhoto(photo: photo) { [unowned self] (errorString) in
            
            if let errorString = errorString {
                self.presentAlertWith(title: errorString, message: "")
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        
        if kind == UICollectionElementKindSectionHeader {
            
            let headerView  = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: mapHeaderIdentifier, for: indexPath) as! VTMapHeaderView
            
            headerView.pin = pin
            
            return headerView
        }
        else {
            
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: refreshFooterIdentifier, for: indexPath) as! VTRefreshFooterView
            
            footerView.refreshButton.addTarget(self, action: #selector(refreshPhotos), for: .touchUpInside)
            
            self.footerView = footerView
            
            return footerView
        }
    }
}

extension VTCoreDataCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: view.frame.height / 3)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.bounds.width / 2 - 24, height: view.bounds.width / 2)
    }
}




