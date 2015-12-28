//
//  FlickrAPI.swift
//  virtualTourist
//
//  Created by Guilherme Carvalho on 12/28/15.
//  Copyright © 2015 Guilherme Carvalho. All rights reserved.
//

import Foundation
// MARK: Lat/Lon Manipulation
class FlickrAPI {
    
    let BASE_URL = "https://api.flickr.com/services/rest/"
    let METHOD_NAME = "flickr.photos.search"
    let API_KEY = "063c04acddf53186989318e3194c08f7"
    let EXTRAS = "url_m"
    let SAFE_SEARCH = "1"
    let DATA_FORMAT = "json"
    let NO_JSON_CALLBACK = "1"
    let BOUNDING_BOX_HALF_WIDTH = 1.0
    let BOUNDING_BOX_HALF_HEIGHT = 1.0
    let LAT_MIN = -90.0
    let LAT_MAX = 90.0
    let LON_MIN = -180.0
    let LON_MAX = 180.0
    
    // MARK: Lat/Lon Manipulation
    func createBoundingBoxString(lat:Double, lon:Double) -> String {
        
        let latitude = lat
        let longitude = lon
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(latitude - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(longitude + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(latitude + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    /* Check to make sure the latitude falls within [-90, 90] */
    func validLatitude(lat:Double) -> Bool {
        let latitude = lat
        if latitude < LAT_MIN || latitude > LAT_MAX {
            return false
        }
        return true
    }
    
    /* Check to make sure the longitude falls within [-180, 180] */
    func validLongitude(lon:Double) -> Bool {
        let longitude = lon
        if longitude < LON_MIN || longitude > LON_MAX {
            return false
        }
        return true
    }
    
    func getLatLonString(lat:Double, lon:Double) -> String {
        let latitude = lat
        let longitude = lon
        
        return "(\(latitude), \(longitude))"
    }
    
    // MARK: Flickr API
    /* Function makes first request to get a random page, then it makes a request to get an image with the random page */
    func getImageFromFlickrBySearch(methodArguments: [String : AnyObject]) {
        
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* Parse the data! */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error? */
            guard let stat = parsedResult["stat"] as? String where stat == "ok" else {
                print("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult["photos"] as? NSDictionary else {
                print("Cannot find keys 'photos' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "pages" key in the photosDictionary? */
            guard let _ = photosDictionary["pages"] as? Int else {
                print("Cannot find key 'pages' in \(photosDictionary)")
                return
            }
            
        }
        
        task.resume()
    }
    
    // MARK: Escape HTML Parameters
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    // MARK: - Shared Image Cache
    struct Caches {
        static let imageCache = ImageCache()
    }

}