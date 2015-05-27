//
//  BeaconManager
//  RangeWhileMonitor
//
//  Created by Gunay Mert Karadogan on 27/5/15.
//  Copyright (c) 2015 Gunay Mert Karadogan. All rights reserved.
//

import Foundation
import CoreLocation

let beaconManagerDidEnterRegionsNotification = "beaconManagerDidEnterRegionsNotification"
let beaconManagerDidExitRegionsNotification = "beaconManagerDidExitRegionsNotification"
let beaconManagerUserInfoEnteredRegionsKey = "enteredRegions"
let beaconManagerUserInfoExitedRegionsKey = "exitedRegions"

class BeaconManager: NSObject, CLLocationManagerDelegate {
    private var manager = CLLocationManager()
    private(set) var currentRegions = Set<CLBeaconRegion>()
    var uuids = [NSUUID?]()
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func startMonitoring() {
        if manager.respondsToSelector("requestAlwaysAuthorization") {
            manager.requestAlwaysAuthorization()
        }
        
        for uuid in uuids {
            if let uuid = uuid {
                let region = CLBeaconRegion(proximityUUID: uuid, identifier: uuid.UUIDString)
                manager.startMonitoringForRegion(region)
            }
        }
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        if let region = region as? CLBeaconRegion {
            switch state {
            case .Inside:
                manager.startRangingBeaconsInRegion(region)
            case .Outside:
                // Let it do ranging for a sec to update currentRegions
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
            NSNotificationCenter.defaultCenter().postNotificationName(beaconManagerDidEnterRegionsNotification, object: self, userInfo: [beaconManagerUserInfoEnteredRegionsKey: enteredRegions])
        }
        
        if exitedRegions.count > 0 {
            NSNotificationCenter.defaultCenter().postNotificationName(beaconManagerDidExitRegionsNotification, object: self, userInfo: [beaconManagerUserInfoExitedRegionsKey: exitedRegions])
        }
    }
    
    // MARK: ()
    func regionFromBeacon(beacon: CLBeacon) -> CLBeaconRegion {
        let major = CLBeaconMajorValue(beacon.major.integerValue)
        let minor = CLBeaconMinorValue(beacon.minor.integerValue)
        let identifier = "\(beacon.proximityUUID.UUIDString).\(major).\(minor)" // Used for "is equal" check in Sets
        return CLBeaconRegion(proximityUUID: beacon.proximityUUID, major: major, minor: minor, identifier: identifier)
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