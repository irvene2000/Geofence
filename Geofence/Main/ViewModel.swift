//
//  ViewModel.swift
//  Geofence
//
//  Created by Tan Way Loon on 04/06/2020.
//  Copyright © 2020 Tan Way Loon. All rights reserved.
//

import Foundation
import MapKit
import RxSwift
import RxCocoa
import SystemConfiguration.CaptiveNetwork
import CoreLocation

enum PositionRelativeToGeofence {
    case undetermined
    case inside
    case outside
}

protocol ViewModelType {
    var geofenceCenter: BehaviorRelay<CLLocationCoordinate2D?> { get }
    var geofenceRadius: BehaviorRelay<Double> { get }
    var ssid: BehaviorRelay<String?> { get }
    var geofenceSSID: BehaviorRelay<String?> { get }
    var position: BehaviorRelay<PositionRelativeToGeofence> { get }
    var userCurrentLocation: BehaviorRelay<CLLocationCoordinate2D?> { get }
    
    func assessPositionRelativeToGeofence()
}

class ViewModel: NSObject, ViewModelType {
    var geofenceCenter: BehaviorRelay<CLLocationCoordinate2D?> = BehaviorRelay(value: nil)
    var geofenceRadius: BehaviorRelay<Double> = BehaviorRelay(value: 10)
    var ssid = BehaviorRelay<String?>(value: nil)
    var geofenceSSID = BehaviorRelay<String?>(value: nil)
    var position = BehaviorRelay<PositionRelativeToGeofence>(value: .undetermined)
    var userCurrentLocation = BehaviorRelay<CLLocationCoordinate2D?>(value: nil)
    
    private lazy var locationManager: CLLocationManager = {
        let newLocationManager = CLLocationManager()
        newLocationManager.delegate = self
        return newLocationManager
    }()
    
    override init() {
        super.init()
        
        getCurrentWifi()
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func getCurrentWifi() {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        self.ssid.accept("Test Wifi")
//        self.ssid.accept(ssid)
    }
    
    func assessPositionRelativeToGeofence() {
        guard let userCurrentLocation = userCurrentLocation.value,
            let geofenceCenter = geofenceCenter.value else {
                position.accept(.undetermined)
                return
        }
        
        let region = CLCircularRegion(center: geofenceCenter, radius: geofenceRadius.value * 1000, identifier: "circle region")
        position.accept(region.contains(userCurrentLocation) ? .inside : .outside)
        
    }
}

extension ViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userCurrentLocation.accept(locations.last?.coordinate)
    }
}
