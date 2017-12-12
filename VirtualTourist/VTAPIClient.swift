import UIKit

class VTAPIClient: NSObject {
    
    static let shared = VTAPIClient()
    
    
    // MARK: - API Call methods
    
    func getPhotoDictionaryPageForCoordinates(lat: Double, lon: Double, page: Int, completionHandler: @escaping(_ results: Array<Any>?, _ errorString: String?) -> Void) {
    
        var methodParameters: [String: AnyObject] = [:]
        methodParameters[Constants.FlickrParameterKeys.APIKey] = Constants.FlickrParameterValues.APIKey as AnyObject
        methodParameters[Constants.FlickrParameterKeys.Method] = Constants.FlickrParameterValues.SearchMethod as AnyObject
        methodParameters[Constants.FlickrParameterKeys.SafeSearch] = Constants.FlickrParameterValues.UseSafeSearch as AnyObject
        methodParameters[Constants.FlickrParameterKeys.Format] = Constants.FlickrParameterValues.ResponseFormat as AnyObject
        methodParameters[Constants.FlickrParameterKeys.NoJSONCallback] = Constants.FlickrParameterValues.DisableJSONCallback as AnyObject
        methodParameters[Constants.FlickrParameterKeys.Extras] = Constants.FlickrParameterValues.MediumURL as AnyObject
        methodParameters[Constants.FlickrParameterKeys.PerPage] = Constants.FlickrParameterValues.PerPage20 as AnyObject
        methodParameters[Constants.FlickrParameterKeys.BoundingBox] = bboxString(lat: lat, lon: lon) as AnyObject
        methodParameters[Constants.FlickrParameterKeys.Page] = page as AnyObject
    
        
        let url = flickrURLFromParameters(methodParameters)
        let request = URLRequest(url: url)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            
            guard (error == nil) else {
                completionHandler(nil, error!.localizedDescription)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completionHandler(nil, "Error: No response in getPhotoForCoordinates")
                return
            }
            
            guard response.statusCode >= 200 && response.statusCode <= 299 else {
                completionHandler(nil, "Error: Status code was NOT successful in getPhotosForCoordinates")
                return
            
            }
            
            guard let data = data else {
                completionHandler(nil, "Error: there was no data in getPhotosForCoordinates")
                return
            }
            
            let parsedData: Any!
            do {
                parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as Any
            }
            catch {
                completionHandler(nil, "Could not deserialize JSON object in getPhotosForCoordinates")
                print(error)
                return
            }
            
//            print(parsedData)
            
            // Extract array as Swift array
            guard let responseDict = (parsedData as! NSDictionary)[Constants.FlickrResponseKeys.Photos] as? NSDictionary else {
                completionHandler(nil, "No dictionary in response in getPhotosForCoordinatea")
                return
            }
            guard let photosArray = responseDict[Constants.FlickrResponseKeys.Photo] as? Array<Dictionary<String, Any>> else {
                completionHandler(nil, "No photo array of dicts in dictionary in getPhotosForCoordinates")
                return
            }
            
            print("photosArray.count: \(photosArray.count)")
            
            // All is well. Handle success
            completionHandler(photosArray, nil)
            
        }
        
        dataTask.resume()
        
    }
    
    
    func getImageWithIdForUrl(url: URL, completionHandler: @escaping(_: UIImage?, _: String) -> Void) {
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            
            guard (error == nil) else {
                print(error!.localizedDescription)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("No response in getImageWithIdForUrl")
                return
            }
            
            guard response.statusCode >= 200 && response.statusCode <= 299 else {
                print("unsuccessful resopnse in getImageWithIdForUrl")
                return
                
            }
            
            guard let data = data else {
                print("No data in getImageWithIdForUrl")
                return
            }
            
            // Success
            // return image or nil if failed to initialize UIImage
            if let realImage = UIImage(data: data) {
                
                completionHandler(realImage, url.absoluteString)
            }
            else {
                completionHandler(nil, url.absoluteString)
            }
        }
        
        dataTask.resume()
        
    }
    
    
    // MARK: - Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String: AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    
    private func bboxString(lat: Double, lon: Double) -> String {
        var lattitude: (Double, Double)!
        var longitude: (Double, Double)!
        
        
            
        var lat1: Double = lat - Constants.Flickr.SearchBBoxHalfHeight
        if lat1 < Constants.Flickr.SearchLatRange.0 {
            lat1 = Constants.Flickr.SearchLatRange.1 + Constants.Flickr.SearchLatRange.1 + lat1
        }
        else if lat1 > Constants.Flickr.SearchLatRange.1 {
            lat1 = Constants.Flickr.SearchLatRange.0 + Constants.Flickr.SearchLatRange.0 + lat1
        }
        
        var lat2: Double = lat + Constants.Flickr.SearchBBoxHalfHeight
        if lat2 < Constants.Flickr.SearchLatRange.0 {
            lat2 = Constants.Flickr.SearchLatRange.1 + Constants.Flickr.SearchLatRange.1 + lat1
        }
        else if lat2 > Constants.Flickr.SearchLatRange.1 {
            lat2 = Constants.Flickr.SearchLatRange.0 + Constants.Flickr.SearchLatRange.0 + lat1
        }
        
        lattitude = (lat1, lat2)
    
        
        
        var lon1: Double = lon - Constants.Flickr.SearchBBoxHalfWidth
        if lon1 < Constants.Flickr.SearchLonRange.0 {
            lon1 = Constants.Flickr.SearchLonRange.1 + Constants.Flickr.SearchLonRange.1 + lon1
        }
        else if lon1 > Constants.Flickr.SearchLonRange.1 {
            lon1 = Constants.Flickr.SearchLonRange.0 + Constants.Flickr.SearchLonRange.0 + lon1
        }
        
        var lon2: Double = lon + Constants.Flickr.SearchBBoxHalfWidth
        if lon2 < Constants.Flickr.SearchLonRange.0 {
            lon2 = Constants.Flickr.SearchLonRange.1 + Constants.Flickr.SearchLonRange.1 + lon2
        }
        else if lon2 > Constants.Flickr.SearchLonRange.1 {
            lon2 = Constants.Flickr.SearchLonRange.0 + Constants.Flickr.SearchLonRange.0 + lon2
        }
        
        longitude = (lon1, lon2)
        
        let bboxString = "\(min(longitude.0, longitude.1)),\(min(lattitude.0, lattitude.1)),\(max(longitude.0, longitude.1)),\(max(lattitude.0, lattitude.1))"
        
        return bboxString
    }
}
