//
//  ViewController.swift
//  virtualTourist
//
//  Created by Guilherme Carvalho on 12/25/15.
//  Copyright © 2015 Guilherme Carvalho. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.mapView.delegate = self
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        let longTap:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "didLongTapMap:")
        longTap.delegate = self
        longTap.numberOfTapsRequired = 0
        longTap.minimumPressDuration = 0.5
        self.mapView.addGestureRecognizer(longTap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Removing the user's location annotation
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        return annotationView
    }
    
    // User tap action
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print(view.annotation?.coordinate)
    }
    
    // Add a pin when there is a long tap
    func didLongTapMap(gestureRecognizer: UIGestureRecognizer) {
        // Get the spot that was tapped.
        let tapPoint: CGPoint = gestureRecognizer.locationInView(mapView)
        let touchMapCoordinate: CLLocationCoordinate2D = mapView.convertPoint(tapPoint, toCoordinateFromView: mapView)

        let viewAtBottomOfHierarchy: UIView = mapView.hitTest(tapPoint, withEvent: nil)!
        if let _ = viewAtBottomOfHierarchy as? MKPinAnnotationView {
            return
        } else {
            if .Began == gestureRecognizer.state {
                let annotation = MKPointAnnotation()
                annotation.coordinate = touchMapCoordinate
                mapView.addAnnotation(annotation)
            }
        }
    }

}