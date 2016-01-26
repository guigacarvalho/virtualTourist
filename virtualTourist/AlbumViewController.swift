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
import CoreData

class AlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate {
    
    var locationPin: Pin!
    
    var photos = [Photo]()
    
    var latitude:Double? = 0.0
    var startEditing:Bool = false
    var longitude:Double? = 0.0
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let regionRadius: CLLocationDistance = 10000
    @IBOutlet weak var photoFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up photoCollectionView and its layout
        photoCollectionView.allowsMultipleSelection = true

        // Persist Pin object
        let dictionary:[String: AnyObject] = [
            "lat": self.latitude!,
            "lon": self.longitude!
        ]
        locationPin = Pin(dictionary: dictionary, context: self.sharedContext)
        
        let space: CGFloat = 0.0
        let flowLength = (self.view.frame.size.width) / 3.0
        
        photoFlowLayout.minimumLineSpacing = space
        photoFlowLayout.minimumInteritemSpacing = space
        photoFlowLayout.itemSize = CGSizeMake(flowLength, flowLength)

        // Do any additional setup after loading the view, typically from a nib.
        let location = CLLocation(latitude: self.latitude!, longitude: self.longitude!)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)

        centerMapOnLocation(location)
        
        let methodArguments:[String: AnyObject] = FlickrAPI.sharedInstance().methodArguments(latitude!, lon: longitude!)
        FlickrAPI.sharedInstance().getImageFromFlickrBySearch(methodArguments) { JSONResult, error  in
            if let error = error {
                print(error)
            } else {
//                print("here")
//                print(JSONResult)
                
                
                /* GUARD: Is "photos" key in our result? */
                guard let photosDictionary = JSONResult["photos"] as? [String : AnyObject] else {
                    print("Cannot find keys 'photos' in \(JSONResult)")
                    return
                }

                guard let photoDictionary = photosDictionary["photo"] as? [[String : AnyObject]] else {
                    print("Cannot find keys 'photo' in \(photosDictionary)")
                    return
                }

                
                photoDictionary.map() { (dictionary: [String : AnyObject]) in
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                        
                        photo.pin = self.locationPin
                        
                        self.photos.append(photo)
                    }
                }

                    // Update the table on the main thread
                    dispatch_async(dispatch_get_main_queue()) {
                        self.photoCollectionView.reloadData()
                        // Save the context
                        self.appDelegate.saveContext()
                    }

            }
        }
     
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
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoItem", forIndexPath: indexPath) as! PhotoCell
        cell.photoImageView.image = UIImage(named: "placeholder")
        let url = NSURL(string: photos[indexPath.row].imagePath!)
        let data = NSData(contentsOfURL: url!)
        let image = UIImage(data: data!)
        cell.photoImageView.image = image!
        
        return cell

    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath)
    {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCell
        cell.highlighted = true
        cell.photoImageView.image = UIImage(named: "placeholder-highlighted")
    }
    
    // MARK: - Core Data Convenience
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return self.appDelegate.managedObjectContext
    }()
    
    
    @IBOutlet weak var removePhotos: UIButton!
    @IBAction func removePhotos(sender: AnyObject) {
        let selectedItems = photoCollectionView.indexPathsForSelectedItems()
        for _ in selectedItems! {
            photos.removeFirst()
        }
        photoCollectionView.deleteItemsAtIndexPaths(selectedItems!)
    }
    
}