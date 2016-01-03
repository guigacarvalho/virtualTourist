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
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var removePinsLabel: UILabel!
    let manager = CLLocationManager()
    var editingPinsEnabled:Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.mapView.delegate = self
        
        self.removePinsLabel.hidden = true
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        let longTap:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "didLongTapMap:")
        longTap.delegate = self
        longTap.numberOfTapsRequired = 0
        longTap.minimumPressDuration = 0.5
        self.mapView.addGestureRecognizer(longTap)
        
        let quickTap:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "didLongTapMap:")
        quickTap.delegate = self
        quickTap.numberOfTapsRequired = 0
        quickTap.minimumPressDuration = 0.5
        self.mapView.addGestureRecognizer(quickTap)
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
        if(self.removePinsLabel.hidden == true) {
            let albumVC = self.storyboard?.instantiateViewControllerWithIdentifier("albumViewCtrl") as! AlbumViewController
            albumVC.latitude = view.annotation!.coordinate.latitude as Double
            albumVC.longitude = view.annotation!.coordinate.longitude as Double
            
            self.navigationController?.pushViewController(albumVC, animated: true)
            mapView.deselectAnnotation(view.annotation, animated: false)

        } else {
            mapView.deselectAnnotation(view.annotation, animated: false)
            mapView.removeAnnotation(view.annotation!)
        }
        
        mapView.deselectAnnotation(view.annotation, animated: false)
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

    
    @IBAction func editButtonClick(sender: AnyObject) {
        editButtonLabelToggle()
    }
    
    func editButtonLabelToggle() {
        self.editingPinsEnabled = !self.editingPinsEnabled
        if(self.editingPinsEnabled) {
            self.editButton.setTitle("Done", forState: UIControlState.Normal)
            self.removePinsLabel.hidden = false
        } else {
            self.editButton.setTitle("Edit", forState: UIControlState.Normal)
            self.removePinsLabel.hidden = true
        }
    }
    
    
    
}