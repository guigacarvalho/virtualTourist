//
//  FlickrAPI.swift
//  virtualTourist
//
//  Created by Guilherme Carvalho on 12/28/15.
//  Copyright © 2015 Guilherme Carvalho. All rights reserved.
//

import Foundation
import UIKit

class FlickrAPI {

    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void

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

    // Importing the AppDelegate
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    // MARK: Lat/Lon Manipulation
    func createBoundingBoxString(lat: Double, lon: Double) -> String {
        
        let latitude = lat
        let longitude = lon
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(latitude - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(longitude + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(latitude + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    func methodArguments(lat: Double, lon:Double) -> [String: AnyObject] {
        return [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "bbox": createBoundingBoxString(lat, lon: lon),
            "safe_search": SAFE_SEARCH,
            "extras": EXTRAS,
            "per_page": 10,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
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
    
    
    // MARK: Flickr API
    /* Function makes first request to get a random page, then it makes a request to get an image with the random page */
    func getImageFromFlickrBySearch(methodArguments: [String : AnyObject],completionHandler: CompletionHander) -> NSURLSessionDataTask {

        
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) { (data, response, downloadError) in
            
            if let error = downloadError {
                let newError = FlickrAPI.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                print("Step 3 - taskForResource's completionHandler is invoked.")
                FlickrAPI.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        
        return task
        
    }
    
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if data == nil {
            return error
        }
        
        do {
            let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            
            print(parsedResult)
            if let parsedResult = parsedResult as? [String : AnyObject], errorMessage = parsedResult["stat"] as? String {
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                return NSError(domain: "TMDB Error", code: 1, userInfo: userInfo)
            }
            
        } catch _ {}
        
        return error
    }
    
    // Parsing the JSON
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHander) {
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            print("Step 4 - parseJSONWithCompletionHandler is invoked.")
            completionHandler(result: parsedResult, error: nil)
        }
    }
    

    
    
    // MARK: - Shared Instance
    class func sharedInstance() -> FlickrAPI {
        
        struct Singleton {
            static var sharedInstance = FlickrAPI()
        }
        
        return Singleton.sharedInstance
    }

    
    // MARK: - Shared Image Cache
    struct Caches {
        static let imageCache = ImageCache()
    }

}