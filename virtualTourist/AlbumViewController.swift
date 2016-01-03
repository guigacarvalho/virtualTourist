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


class AlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate {

    var photos:[Int] = [0,0,0,0,0,0,0,0,0,0,0]
    var latitude:Double?
    var startEditing:Bool = false
    var longitude:Double?
    let regionRadius: CLLocationDistance = 10000
    @IBOutlet weak var photoFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up photoCollectionView and its layout
        photoCollectionView.allowsMultipleSelection = true
        
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
        
//        let methodArguments:[String: AnyObject] = FlickrAPI.sharedInstance().methodArguments(latitude!, lon: longitude!)
//        print(FlickrAPI.sharedInstance().getImageFromFlickrBySearch(methodArguments))
     
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
    @IBOutlet weak var removePhotos: UIButton!
    @IBAction func removePhotos(sender: AnyObject) {
        let selectedItems = photoCollectionView.indexPathsForSelectedItems()
        for _ in selectedItems! {
            photos.removeFirst()
        }
        photoCollectionView.deleteItemsAtIndexPaths(selectedItems!)
    }
    
}