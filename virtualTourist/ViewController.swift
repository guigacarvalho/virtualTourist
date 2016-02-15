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
import CoreData



class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var removePinsLabel: UILabel!
    let manager = CLLocationManager()
    var editingPinsEnabled:Bool = false
    var locationPins = [Pin]()

    

    
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
        mapView.deselectAnnotation(view.annotation, animated: false)
        if(self.removePinsLabel.hidden == true) {
            let albumVC = self.storyboard?.instantiateViewControllerWithIdentifier("albumViewCtrl") as! AlbumViewController
            albumVC.latitude = view.annotation!.coordinate.latitude as Double
            albumVC.longitude = view.annotation!.coordinate.longitude as Double
            let dictionary:[String: AnyObject] = [
                "lat": view.annotation!.coordinate.latitude,
                "lon": view.annotation!.coordinate.longitude
            ]
            
            let tempPin = locationPins.filter({
                $0.lon == dictionary["lon"] as! NSNumber && $0.lon == dictionary["lon"] as! NSNumber
            })[0]
            
            albumVC.locationPin = tempPin
            
            self.navigationController?.pushViewController(albumVC, animated: true)
        } else {
            mapView.removeAnnotation(view.annotation!)
        }
         

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

                let dictionary:[String: AnyObject] = [
                    "lat": annotation.coordinate.latitude,
                    "lon": annotation.coordinate.longitude
                ]
                let locationPin = Pin(dictionary: dictionary, context: self.sharedContext)
                locationPins.append(locationPin)
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
    
    
    // MARK: - Core Data Convenience
    lazy var sharedContext: NSManagedObjectContext =  {
        return self.appDelegate.managedObjectContext
    }()
    
    
}