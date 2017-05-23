//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Dean Copeland on 5/1/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController,  MKMapViewDelegate {
    
    var editMode = false

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var editOrDoneButton: UIBarButtonItem!
    
    @IBOutlet weak var tapPinsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        tapPinsLabel.alpha = 0.0
        
        // Create a simple fetchrequest to get all pins (no sorting needed)
        let fr: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        let context = stack.context
        var fetchedPins: [Pin]?
        context.performAndWait ({
            do {
                fetchedPins = try context.fetch(fr)
            } catch let error {
                self.alert(message: error.localizedDescription)
            }
        })
        
        if let pins = fetchedPins {
            //print("Found \(pins.count) pins")
            for pin in pins {
                let annotation = PinAnnotation()
                let coordinates = CLLocationCoordinate2D(latitude: Double(pin.latitude), longitude: Double(pin.longitude))
                
                annotation.coordinate = coordinates
                annotation.pin = pin
                mapView.addAnnotation(annotation)
            
            }
        }
        
        setMapRegion()
        activityIndicator.stopAnimating()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveMapRegion()
    }
    
    private func saveMapRegion() {
        // Save the map region displayed
        UserDefaults.standard.set(mapView.region.center.latitude,
                                  forKey: Defaults.CenterLatitude)
        UserDefaults.standard.set(mapView.region.center.longitude,
                                  forKey: Defaults.CenterLongitude)
        UserDefaults.standard.set(mapView.region.span.latitudeDelta,
                                  forKey: Defaults.SpanLatitude)
        UserDefaults.standard.set(mapView.region.span.longitudeDelta,
                                  forKey: Defaults.SpanLongitude)
        
        UserDefaults.standard.synchronize()
    }
    
    func setMapRegion() {
        // Set the map location
        //print("Setting the map location")
        let centerLat = UserDefaults.standard.double(forKey: Defaults.CenterLatitude)
        let centerLon = UserDefaults.standard.double(forKey: Defaults.CenterLongitude)
        let centerCoordinate = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
        
        let spanLat = UserDefaults.standard.double(forKey: Defaults.SpanLatitude)
        let spanLon = UserDefaults.standard.double(forKey: Defaults.SpanLongitude)
        let span = MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon)
        
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    

    @IBAction func edit(_ sender: Any) {
        
        if editMode {
            editOrDoneButton.title = "Edit"
            editMode = false
            UIView.animate(withDuration: 0.5, animations: {
                self.tapPinsLabel.alpha = 0.0
            })
        } else {
            editOrDoneButton.title = "Done"
            editMode = true
            UIView.animate(withDuration: 0.5, animations: {
                self.tapPinsLabel.alpha = 1.0
            })
            
        }
        
        
    }
    
    @IBAction func addPin(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            let touchPoint = recognizer.location(in: mapView)
            let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            //let annotation = MKPointAnnotation()
            let annotation = PinAnnotation()
            annotation.coordinate = coordinates
            mapView.addAnnotation(annotation)
            
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let stack = delegate.stack
            
            let pin = Pin(latitude: Float(coordinates.latitude), longitude: Float(coordinates.longitude), context: stack.context)
            
            annotation.pin = pin
            
            //print("Created a pin: \(pin)")
            
            stack.save()
            
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotoAlbum" {
            let backItem = UIBarButtonItem()
            backItem.title = "OK"
            navigationItem.backBarButtonItem = backItem
            let destinationVC = segue.destination as! PhotoAlbumViewController
            let pinAnnotation = sender as! PinAnnotation
            destinationVC.pin = pinAnnotation.pin
        }
    }

    // MARK: Map delegate
    //Annotation view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if(pinView == nil) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.animatesDrop = true
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect: MKAnnotationView) {
        print("Pin clicked")
        
        let pinAnnotation = didSelect.annotation as! PinAnnotation
        
        mapView.deselectAnnotation(pinAnnotation, animated: true)
        if editMode {
            let pin = pinAnnotation.pin
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let stack = delegate.stack
            let context = stack.context
            context.delete(pin!)
            stack.save()
            mapView.removeAnnotation(pinAnnotation)
        } else {
            performSegue(withIdentifier: "ShowPhotoAlbum", sender: pinAnnotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated: Bool) {
        saveMapRegion()
    }
    
    
}
