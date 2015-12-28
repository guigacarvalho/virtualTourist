//
//  AlbumViewController.swift
//  virtualTourist
//
//  Created by Guilherme Carvalho on 12/27/15.
//  Copyright © 2015 Guilherme Carvalho. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class AlbumViewController: UIViewController, MKMapViewDelegate {
    
    var latitude:Double?
    var longitude:Double?
    let regionRadius: CLLocationDistance = 10000
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let location = CLLocation(latitude: self.latitude!, longitude: self.longitude!)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)

        centerMapOnLocation(location)
        
        let methodArguments:[String: AnyObject] = FlickrAPI.sharedInstance().methodArguments(latitude!, lon: longitude!)
        print(FlickrAPI.sharedInstance().getImageFromFlickrBySearch(methodArguments))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

}