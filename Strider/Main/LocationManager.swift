//
//  LocationManager.swift
//  Strider
//
//  Created by Matt Phelps on 2018-09-07.
//  Copyright © 2018 Matt Phelps. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class LocationManager: UIViewController, CLLocationManagerDelegate {
    
    let locationManager: CLLocationManager = CLLocationManager()
    let userLocationId = "userLocationId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 1000
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations[0]
            let latitude = currentLocation.coordinate.latitude
            let longitude = currentLocation.coordinate.longitude
            let userLocation = CLLocationCoordinate2DMake(latitude, longitude)
            let geoFenceRegion: CLCircularRegion = CLCircularRegion(center: userLocation, radius: 5000, identifier: userLocationId)
            locationManager.startMonitoring(for: geoFenceRegion)
          //  saveUserLocation(location: currentLocation)
    }
    
    func saveUserLocation(location: CLLocation) {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let values = ["location" : location]
            let ref = Database.database().reference().child("locations").child(uid)
            ref.updateChildValues(values) { (err, _) in
                if let err = err {
                    print("Failed to update user's location:", err)
                }
                print("Successfully updated user's location")
            }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Sandy muffin")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Saucy Sally")
    }
    
}
