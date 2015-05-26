//
//  ViewController.swift
//  RangeWhileMonitor
//
//  Created by Gunay Mert Karadogan on 26/5/15.
//  Copyright (c) 2015 Gunay Mert Karadogan. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manager.delegate = self
        requestAlwaysAuthorization() // Shows an alert if authorization was determined earlier
        
        if let uuid = NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D") {
            let region = CLBeaconRegion(proximityUUID: uuid, identifier: uuid.UUIDString)
            manager.startMonitoringForRegion(region)
        }
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        if let region = region as? CLBeaconRegion {
            // region.major and region.minor will return nil
            println("Entered in region with UUID: \(region.proximityUUID) Major: \(region.major) Minor: \(region.minor)")
        }
    }

    // MARK: ()
    func requestAlwaysAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            break
        case .NotDetermined:
            manager.requestAlwaysAuthorization()
        case .AuthorizedWhenInUse, .Restricted, .Denied:
            let alertController = UIAlertController(
                title: "Background Location Access Disabled",
                message: "In order to be notified about iBeacons near you, please open this app's settings and set location access to 'Always'.",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

}

