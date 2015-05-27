//
//  ViewController.swift
//  RangeWhileMonitor
//
//  Created by Gunay Mert Karadogan on 26/5/15.
//  Copyright (c) 2015 Gunay Mert Karadogan. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    let beaconManager = BeaconManager()
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterRegions:", name: beaconManagerDidEnterRegionsNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didExitRegions:", name: beaconManagerDidExitRegionsNotification, object: nil)
        
        beaconManager.uuids = [NSUUID(UUIDString: "8492E75F-4FD6-469D-B132-043FE94921D8"),
                                NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")]
        beaconManager.startMonitoring()
    }
    
    func didEnterRegions(notification: NSNotification) {
        if let regions = notification.userInfo?[beaconManagerUserInfoEnteredRegionsKey] as? Set<CLBeaconRegion> {
            let title = "You entered a region!"
            for region in regions {
                let message = "\(region.proximityUUID.UUIDString) \(region.major) \(region.minor)"
                presentLocalNotificationNow(title, message: message)
            }
        }
    }

    func didExitRegions(notification: NSNotification) {
        if let regions = notification.userInfo?[beaconManagerUserInfoExitedRegionsKey] as? Set<CLBeaconRegion> {
            let title = "You exited a region!"
            for region in regions {
                let message = "\(region.proximityUUID.UUIDString) \(region.major) \(region.minor)"
                presentLocalNotificationNow(title, message: message)
            }
        }
    }
    
    func presentLocalNotificationNow(title: String, message: String) {
        let notification = UILocalNotification()
        notification.alertBody = message
        notification.alertTitle = title
        
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
}

