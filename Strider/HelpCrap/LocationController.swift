//
//  LocationController.swift
//  Strider
//
//  Created by Matt Phelps on 2018-08-16.
//  Copyright © 2018 Matt Phelps. All rights reserved.
//

import UIKit
import CoreLocation

class LocationController : UIViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = CLActivityType.other
   //     locationManager.allowsBackgroundLocationUpdates = true  // THIS CAUSES THE APP TO CREASH WITH NX EXCEPTION ERROR
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
    }
   
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("location:: (location)")
        }
    }
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: (error)")
    }

}


