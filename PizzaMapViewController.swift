//
//  PizzaMapViewController.swift
//  PizzaMap
//
//  Created by James O'Connor on 7/27/16.
//  Copyright © 2016 James O'Connor. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PizzaMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var pizzaSpots = [PizzaSpot]()
    
    var locationManager :CLLocationManager!
    
    @IBOutlet weak var mapView :MKMapView!
    @IBOutlet weak var detailView :UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        self.mapView.showsUserLocation = true
        
        // Do any additional setup after loading the view.
        
        populateAlbum()
    }
    
    private func populateAlbum() {
        
        let pizzaAPI = "https://dl.dropboxusercontent.com/u/20116434/locations.json"
        
        guard let url = NSURL(string: pizzaAPI) else {fatalError("Invalid API")}
        
        let session = NSURLSession.sharedSession()
        
        session.dataTaskWithURL(url) { (data :NSData?, response :NSURLResponse?, error :NSError?) in
            
            let jsonPizzaArray = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [AnyObject]
            
            for item in jsonPizzaArray {
                
                let pizzaSpot = PizzaSpot()
                pizzaSpot.pizzaLat = item.valueForKey("latitude") as! Double
                pizzaSpot.pizzaLong = item.valueForKey("longitude") as! Double
                pizzaSpot.spotName = item.valueForKey("name") as! String
                
                
                self.pizzaSpots.append(pizzaSpot)
                
                let pinAnnotation = MKPointAnnotation()
                pinAnnotation.coordinate = CLLocationCoordinate2D(latitude: pizzaSpot.pizzaLat, longitude: pizzaSpot.pizzaLong)
                pinAnnotation.title = pizzaSpot.spotName
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.mapView.addAnnotation(pinAnnotation)
                })
                
            }
         
        
        }.resume()
        
        
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        
        if let annotationView = views.first {
            
            if let annotation = annotationView.annotation {
                
                if annotation is MKUserLocation {
                    
                    let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
                    
                    self.mapView.setRegion(region, animated: true)
                    
                }
                
            }
            
        }
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation:MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            
            return nil
            
        }
        
        var pizzaAnnotationView =
            
            self.mapView.dequeueReusableAnnotationViewWithIdentifier("PizzaAnnotationView")
        
        if pizzaAnnotationView == nil {
            
            pizzaAnnotationView = PizzaAnnotationView(annotation: annotation, reuseIdentifier: "PizzaAnnotationView")
            
        }
        
        pizzaAnnotationView?.canShowCallout = true
        pizzaAnnotationView?.detailCalloutAccessoryView = self.detailView
        
        return pizzaAnnotationView
        
    }
    
    
        

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}
