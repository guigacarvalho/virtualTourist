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



class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
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
        
        // Recreating Pins
        do {
            try fetchedPinsController.performFetch()
        } catch _ {
            print("Problem fetching pins!")
        }
        locationPins = self.fetchedPinsController.fetchedObjects as! [Pin]
        for item in locationPins {
            let coordinate = CLLocationCoordinate2D(latitude: Double(item.lat), longitude: Double(item.lon))
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            self.mapView.addAnnotation(annotation)
        }

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
        let lat = view.annotation!.coordinate.latitude as Double
        let lon = view.annotation!.coordinate.longitude as Double
        if(self.removePinsLabel.hidden == true) {
            let albumVC = self.storyboard?.instantiateViewControllerWithIdentifier("albumViewCtrl") as! AlbumViewController
            albumVC.latitude = lat
            albumVC.longitude = lon
            
            albumVC.locationPin = getPinFromAnnotation(lat, longitude: lon)
            
            self.navigationController?.pushViewController(albumVC, animated: true)
        } else {
            mapView.removeAnnotation(view.annotation!)
            
            let tempPin = getPinFromAnnotation(lat, longitude: lon)
            let fetchedPhotosController: NSFetchedResultsController = fetchPhotosforPin(tempPin)

            do {
                try fetchedPhotosController.performFetch()
            } catch _ {
                print("Problem fetching pins!")
            }
            let photos = fetchedPhotosController.fetchedObjects as! [Photo]

            // Removing photos from that Pin
            for photo in photos {
                photo.image = nil
                dispatch_async(dispatch_get_main_queue()) {
                    self.sharedContext.deleteObject(photo)
                    self.appDelegate.saveContext()
                }
            }
            
            // Removing the Pin itself
            dispatch_async(dispatch_get_main_queue()) {
                // Remove pins from DB, Array and File System
                self.sharedContext.deleteObject(tempPin)
                self.appDelegate.saveContext()
            }
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
                appDelegate.saveContext()
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
    
    func getPinFromAnnotation(latitude:Double, longitude:Double) -> Pin {
        let dictionary:[String: AnyObject] = [
            "lat": latitude,
            "lon": longitude
        ]
        
        let tempPin = locationPins.filter({
            $0.lon == dictionary["lon"] as! NSNumber && $0.lon == dictionary["lon"] as! NSNumber
        })[0]

        return tempPin
    }
    
    // MARK: - Core Data Convenience
    lazy var sharedContext: NSManagedObjectContext =  {
        return self.appDelegate.managedObjectContext
    }()
    
    
    lazy var fetchedPinsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lat", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()

    
    func fetchPhotosforPin(locationPin:Pin) -> NSFetchedResultsController {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", locationPin);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }

    
}