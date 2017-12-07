import Foundation
import UIKit

extension UIViewController {
    
    func presentAlertWith(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
    
    func dimScreenWithActivitySpinner() {
        
        DispatchQueue.main.async { [unowned self] in
            
            // Add dimmed view
            let dimmedView = UIView(frame: self.view.window?.frame ?? self.view.frame)
            dimmedView.tag = 1
            dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            self.view.window?.addSubview(dimmedView)
        
            // Add activity indicator
            let spinnerView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            spinnerView.tag = 1
            spinnerView.center = CGPoint(x: self.view.center.x, y: self.view.center.y - self.navigationController!.navigationBar.frame.height)
            self.view.window?.addSubview(spinnerView)
            spinnerView.startAnimating()
        }
    }
    
    func undimScreenAndRemoveActivitySpinner() {
        
        DispatchQueue.main.async { [unowned self] in
            
            if let window = self.view.window {
                
                for view in window.subviews {
                    
                    if view.tag == 1 {
                        
                        view.removeFromSuperview()
                    }
                }
            }
        }
    }
    
}
