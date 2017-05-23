//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Dean Copeland on 5/2/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private let reuseIdentifier = "PhotoCell"
    
    // MARK: Properties
    var pin: Pin?
    
    var photosToDownload = 0
    
    //Set the title of the Tool Button accordingly.
    var selectedPhotos = [IndexPath]() {
        didSet {
            if selectedPhotos.isEmpty {
                newCollectionButton.isHidden = false
                deleteSelectedPhotosButton.isHidden = true
            } else {
                newCollectionButton.isHidden = true
                deleteSelectedPhotosButton.isHidden = false
            }
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var newCollectionButton: UIButton!
    
    @IBOutlet weak var deleteSelectedPhotosButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var noImagesLabel: UILabel!
    
    // Create a fetchrequest
    let fr: NSFetchRequest<Pin> = Pin.fetchRequest()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Photo> = {
        let fr: NSFetchRequest<Photo> = Photo.fetchRequest()
        fr.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fr.predicate = NSPredicate(format: "pin == %@", self.pin!)
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        newCollectionButton.isEnabled = false
        deleteSelectedPhotosButton.isHidden = true
        noImagesLabel.isHidden = true
        
        setupMap()
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error {
            print("Core Data fetch failed: \(error)")
            alert(message: error.localizedDescription)
        }
        
        let space: CGFloat = 2.0
        let dimension = (self.collectionView.frame.size.width - (2 * space)) / 4.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        if pin?.photos?.count == 0 {
            // If no photos info in Core data, then need to get the info from Flickr
            print("Getting photo data from Flickr...")
            getPhotosFromFlickr()
            
        } else {
            print("Using locally saved photo data")
            self.newCollectionButton.isEnabled = true
        }
    }
    
    private func getPhotosFromFlickr() {
        
        if let pin = pin {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let stack = delegate.stack
            activityIndicator.startAnimating()
            noImagesLabel.isHidden = true
            FlickrClient.sharedInstance().photosForLocation(pin, nil, context: stack.context) {(results, error) in
                if let _ = results {
                    performUIUpdatesOnMain {
                        stack.save()
                        do {
                            try self.fetchedResultsController.performFetch()
                        } catch let error {
                            print("Core Data fetch failed: \(error)")
                            self.alert(message: error.localizedDescription)
                        }
                        if self.fetchedResultsController.fetchedObjects?.count == 0 {
                            self.noImagesLabel.isHidden = false
                        } else {
                            self.photosToDownload = (self.fetchedResultsController.fetchedObjects?.count)!
                        }
                        self.collectionView.reloadData()
                        self.activityIndicator.stopAnimating()
                        //self.newCollectionButton.isEnabled = true
                    }
                } else {
                    performUIUpdatesOnMain {
                        self.newCollectionButton.isEnabled = true
                        self.alert(title: "No photos retrieved from Flickr", message: error?.description)
                        self.noImagesLabel.isHidden = false
                    }
                }
            }
        } else {
            alert(message: "Pin was not set")
        }
    }
    
    private func setupMap() {
        // Set the map location
        if let pin = pin {
            print("Setting the map location")
            let centerLat = Double(pin.latitude)
            let centerLon = Double(pin.longitude)
            let centerCoordinate = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
            
            // Use the same span as the map on the previous page
            let spanLat = UserDefaults.standard.double(forKey: Defaults.SpanLatitude)
            let spanLon = UserDefaults.standard.double(forKey: Defaults.SpanLongitude)
            let span = MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon)
            
            let region = MKCoordinateRegion(center: centerCoordinate, span: span)
            mapView.setRegion(region, animated: true)
            
            
            let annotation = PinAnnotation()
            let coordinates = CLLocationCoordinate2D(latitude: Double(pin.latitude), longitude: Double(pin.longitude))
            
            annotation.coordinate = coordinates
            annotation.pin = pin
            mapView.addAnnotation(annotation)
        }
        
    }

    
    // MARK: Actions
    @IBAction func newCollectionPressed(_ sender: Any) {
        
        newCollectionButton.isEnabled = false
        
        // Delete all of the photos for this pin location
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        for photo in fetchedResultsController.fetchedObjects! {
            stack.context.delete(photo)
        }
        stack.save()
        
        // Get new photos
        getPhotosFromFlickr()
    }
    
    @IBAction func deleteSelectedPhotosPressed(_ sender: Any) {
        
        // Delete the selected photos for this pin location
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        for indexPath in selectedPhotos {
            let photo = fetchedResultsController.object(at: indexPath)
            stack.context.delete(photo)
        }
        stack.save()
        //self.collectionView.deleteItems(at: selectedPhotos)
        do {
            try fetchedResultsController.performFetch()
            self.collectionView.reloadData()
        } catch let error {
            print("Core Data fetch failed: \(error)")
            self.alert(message: error.localizedDescription)
        }
        
        selectedPhotos = []
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // Return the number of sections
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of items
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        print("\(sectionInfo.numberOfObjects) photos")
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        //print("cellForItemAt called")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
        
        // Configure the cell
        cell.alpha = 1.0
        cell.activityIndicator.stopAnimating()
        let photo = fetchedResultsController.object(at: indexPath)
        
        if let imageData = photo.imageData {
            // We already have this image in CoreData
            cell.imageView.image = UIImage(data: imageData)
        } else {
            // Need to fetch it from Flickr
            // Set a placeholder image
            cell.imageView.image = UIImage(named: "FlickrIcon")
            cell.activityIndicator.startAnimating()
            FlickrClient.sharedInstance().getImageForPhoto(photo) { (data, error) in
                if let data = data {
                    photo.imageData = data
                    performUIUpdatesOnMain {
                        cell.imageView.image = UIImage(data: data)
                        cell.activityIndicator.stopAnimating()
                        self.photosToDownload -= 1
                        if self.photosToDownload == 0 {
                            self.newCollectionButton.isEnabled = true
                        }
                    }
                } else {
                    print("Failed to get image data from Flickr")
                    performUIUpdatesOnMain {
                        cell.imageView.image = nil
                        cell.activityIndicator.stopAnimating()
                        self.alert(message: "Failed to get image data from Flickr")
                    }
                }
            }
        }
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        
        if let index = selectedPhotos.index(of: indexPath) {
            // Already selecgted it: Deselect it
            selectedPhotos.remove(at: index)
            cell.alpha = 1.0
        } else {
            // Not yet selected yet: Select it
            selectedPhotos.append(indexPath)
            cell.alpha = 0.3
        }
    }
}
