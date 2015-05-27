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
    var currentRegions = Set<CLBeaconRegion>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manager.delegate = self
        requestAlwaysAuthorization() // Shows an alert if authorization was determined earlier
        
        if let uuid = NSUUID(UUIDString: "8492E75F-4FD6-469D-B132-043FE94921D8") {
            let region = CLBeaconRegion(proximityUUID: uuid, identifier: uuid.UUIDString)
            manager.startMonitoringForRegion(region)
        }
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        if let region = region as? CLBeaconRegion {
            switch state {
            case .Inside:
                manager.startRangingBeaconsInRegion(region)
            case .Outside:
                delay(1.0) {
                    manager.stopRangingBeaconsInRegion(region)
                }
            case .Unknown:
                break
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        var latestRegions = Set<CLBeaconRegion>()
        
        // Create CLBeaconRegions from CLBeacons
        if let beacons = beacons as? [CLBeacon] {
            for beacon in beacons {
                latestRegions.insert(regionFromBeacon(beacon))
            }
        }
        
        let enteredRegions = latestRegions.subtract(currentRegions)
        let exitedRegions = currentRegions.subtract(latestRegions)
        currentRegions = latestRegions
        
        if enteredRegions.count > 0 {
            println("Entered")
            println(enteredRegions)
        }
        
        if exitedRegions.count > 0 {
            println("Exited")
            println(exitedRegions)
        }
    }

    // MARK: ()
    func regionFromBeacon(beacon: CLBeacon) -> CLBeaconRegion {
        let major = CLBeaconMajorValue(beacon.major.integerValue)
        let minor = CLBeaconMinorValue(beacon.minor.integerValue)
        let identifier = "\(beacon.proximityUUID.UUIDString).\(major).\(minor)" // Used for "is equal" check in Sets
        return CLBeaconRegion(proximityUUID: beacon.proximityUUID, major: major, minor: minor, identifier: identifier)
    }
    
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
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}

