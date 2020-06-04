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
    func updateGeofenceCenter(_ center: CLLocationCoordinate2D?)
    func updateGeofenceRadius(_ radius: Double)
    func updateGeofenceSSID(_ geofenceSSID: String?)
}

class ViewModel: NSObject, ViewModelType {
    // MARK: - Properties -
    // MARK: Internal
    
    var geofenceCenter: BehaviorRelay<CLLocationCoordinate2D?> = BehaviorRelay(value: nil)
    var geofenceRadius: BehaviorRelay<Double> = BehaviorRelay(value: 10)
    var ssid = BehaviorRelay<String?>(value: nil)
    var geofenceSSID = BehaviorRelay<String?>(value: nil)
    var position = BehaviorRelay<PositionRelativeToGeofence>(value: .undetermined)
    var userCurrentLocation = BehaviorRelay<CLLocationCoordinate2D?>(value: nil)
    
    // MARK: Private
    
    private lazy var locationManager: CLLocationManager = {
        let newLocationManager = CLLocationManager()
        newLocationManager.delegate = self
        return newLocationManager
    }()
    private var timer : Timer!
    
    // MARK: - Initializer and Lifecycle Methods -
    
    override init() {
        super.init()
        
        getCurrentWifi()
        startTimer()
        locationManager.requestWhenInUseAuthorization()
    }
    
    deinit {
        stopTimer()
    }
    
    // MARK: - Internal API -
    // MARK: Input Methods
    
    func assessPositionRelativeToGeofence() {
        var position: PositionRelativeToGeofence = .undetermined
        
        if let geofenceSSID = geofenceSSID.value,
            let ssid = ssid.value,
            geofenceSSID.lowercased() == ssid.lowercased() {
            position = .inside
        }
        
        if position == .undetermined,
            let userCurrentLocation = userCurrentLocation.value,
            let geofenceCenter = geofenceCenter.value {
            let region = CLCircularRegion(center: geofenceCenter, radius: geofenceRadius.value * 1000, identifier: "circle region")
            position = region.contains(userCurrentLocation) ? .inside : .outside
        }
        
        self.position.accept(position)
    }
    
    func updateGeofenceCenter(_ center: CLLocationCoordinate2D?) {
        geofenceCenter.accept(center)
    }
    
    func updateGeofenceRadius(_ radius: Double) {
        geofenceRadius.accept(radius)
    }
    
    func updateGeofenceSSID(_ geofenceSSID: String?) {
        self.geofenceSSID.accept(geofenceSSID)
    }
    
    // MARK: - Private API -
    // MARK: Timer Methods
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(getCurrentWifi), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        guard timer != nil else { return }
            
        timer.invalidate()
        timer = nil
    }
    
    // MARK: Callback Methods
    
    @objc private func getCurrentWifi() {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        
        // NOTE: Uncomment line 85 and 86 and comment out 87 if you want to test the SSID function with a mock value
//        let randomNumber = Int.random(in: 1...5)
//        self.ssid.accept("Test Wifi \(randomNumber)")
        self.ssid.accept(ssid)
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
