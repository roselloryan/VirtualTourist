import UIKit

class VTTesetViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        VTAPIClient.shared.getPhotoDictionariesForCoordinates(lat: 10, lon: 10) { (resultsArray, errorString) in
            
            if let error = errorString {
                print(error)
            }
            if let results = resultsArray {
                print(results)
                
            }
        }
    }

}
