//
//  ViewController.swift
//  Strider
//
//  Created by Matt Phelps on 2018-07-21.
//  Copyright © 2018 Matt Phelps. All rights reserved.
//

import UIKit
import MapKit

class MapController: UIViewController, CLLocationManagerDelegate {

    var coreLocationManager = CLLocationManager()
    var locationManager: LocationManager!
    var window: UIWindow?
    var mapView: MKMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.window = UIWindow()
        self.view.backgroundColor = .white
        
        self.mapView = MKMapView(frame: CGRect(x: 0, y: 20, width: (self.window?.frame.width)!, height: ((self.window?.frame.height)! - 100)))
        self.view.addSubview(self.mapView!)
        
        coreLocationManager.delegate = self
        locationManager = LocationManager.sharedInstance
        
        let authorisationCode = CLLocationManager.authorizationStatus()
        
        if authorisationCode == CLAuthorizationStatus.notDetermined && coreLocationManager.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)) || coreLocationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
            
            if Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysUsageDescription") != nil {
                coreLocationManager.requestAlwaysAuthorization()
            } else {
                print("No description provided")
            }

        } else {
            getLocation()
        }
    }
    
    func getLocation() {
        locationManager.startUpdatingLocationWithCompletionHandler { (latitude, longitude, status, verboseMessage, error) in
            self.displayLocation(location: CLLocation(latitude: latitude, longitude: longitude))
        }
    }
    
    func displayLocation(location: CLLocation) {
        let latitude = location.coordinate.latitude
        let longtiude = location.coordinate.longitude
        let span = MKCoordinateSpanMake(0.05, 0.5)
        mapView?.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2DMake(latitude, longtiude), span: span), animated: true)
        
        let locationPinCoord = CLLocationCoordinate2D(latitude: latitude, longitude: longtiude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationPinCoord
        
        mapView?.addAnnotation(annotation)
        mapView?.showAnnotations([annotation], animated: true)
        
        locationManager.reverseGeocodeLocationWithCoordinates(location) { (reverseGecodeInfo, placemark, error) in
            let address = reverseGecodeInfo?.object(forKey: "formattedAddress") as! String
            //Attach to label - self.locationInfoLabel.text = address
        }
    }
    
    // For update location Button - call the getLocation() function
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != CLAuthorizationStatus.notDetermined || status != CLAuthorizationStatus.denied || status != CLAuthorizationStatus.restricted {
            getLocation()
        }
    }

}










