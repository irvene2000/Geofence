//
//  ViewModelTests.swift
//  GeofenceTests
//
//  Created by Tan Way Loon on 04/06/2020.
//  Copyright © 2020 Tan Way Loon. All rights reserved.
//

import Foundation
import XCTest
import CoreLocation
import RxCocoa
import RxSwift

@testable import Geofence

class ViewModelTests: XCTestCase {
    var viewModel: ViewModel!
    
    override func setUp() {
        viewModel = ViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
    }
    
    func testDefaultGeofenceCenterValue() {
        XCTAssertNil(viewModel.geofenceCenter.value)
    }
    
    func testDefaultGeofenceRadiusValue() {
        XCTAssert(viewModel.geofenceRadius.value == 10)
    }
    
    func testDefaultSSIDValue() {
        XCTAssertNil(viewModel.ssid.value)
    }
    
    func testDefaultGeofenceSSIDValue() {
        XCTAssertNil(viewModel.geofenceSSID.value)
    }
    
    func testDefaultPositionValue() {
        XCTAssert(viewModel.position.value == .undetermined)
    }
    
    func testDefaultUserCurrentLocationValue() {
        XCTAssertNil(viewModel.userCurrentLocation.value)
    }
    
    func testUpdateGeofenceCenter() {
        let coordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        viewModel.updateGeofenceCenter(coordinate)
        let geofenceCenterValue = viewModel.geofenceCenter.value
        XCTAssert(geofenceCenterValue?.latitude == coordinate.latitude)
        XCTAssert(geofenceCenterValue?.longitude == coordinate.longitude)
    }
    
    func testUpdateGeofenceCenterToNil() {
        viewModel.updateGeofenceCenter(nil)
        let geofenceCenterValue = viewModel.geofenceCenter.value
        XCTAssertNil(geofenceCenterValue)
    }
    
    func testUpdateGeofenceRadius() {
        viewModel.updateGeofenceRadius(20.0)
        XCTAssert(viewModel.geofenceRadius.value == 20.0)
    }

    func testUpdateGeofenceSSID() {
        let testSSID = "test_wifi"
        viewModel.updateGeofenceSSID(testSSID)
        XCTAssert(viewModel.geofenceSSID.value == "test_wifi")
    }
    
    func testUpdateGeofenceSSIDToNil() {
        viewModel.updateGeofenceSSID(nil)
        XCTAssertNil(viewModel.geofenceSSID.value)
    }
    
    func testDefaultPositionBeforeDeterminingSSIDAndGeofence() {
        viewModel.assessPositionRelativeToGeofence()
        XCTAssert(viewModel.position.value == .undetermined)
    }
    
    func testPositionWhenSSIDHasBeenEstablishedButDoesNotMatch() {
        let testSSID = "test_wifi"
        viewModel.updateGeofenceSSID(testSSID)
        let otherSSID = "other_wifi"
        viewModel.ssid.accept(otherSSID)
        viewModel.assessPositionRelativeToGeofence()
        XCTAssert(viewModel.position.value == .undetermined)
    }
    
    func testPositionWhenSSIDHasBeenEstablishedAndMatchGeofenceWifi() {
        let testSSID = "test_wifi"
        viewModel.updateGeofenceSSID(testSSID)
        viewModel.ssid.accept(testSSID)
        viewModel.assessPositionRelativeToGeofence()
        XCTAssert(viewModel.position.value == .inside)
    }
    
    func testPositionWhenMatchingSSIDButOutsideBoundsOfGeoFence() {
        let testSSID = "test_wifi"
        viewModel.updateGeofenceSSID(testSSID)
        viewModel.ssid.accept(testSSID)
        viewModel.updateGeofenceCenter(CLLocationCoordinate2D(latitude: 0, longitude: 0))
        viewModel.userCurrentLocation.accept(CLLocationCoordinate2DMake(10.0, 10.0))
        viewModel.assessPositionRelativeToGeofence()
        XCTAssert(viewModel.position.value == .inside)
    }
    
    func testPositionWhenNonMatchingSSIDButOutsideBoundsOfGeoFence() {
        let testSSID = "test_wifi"
        viewModel.updateGeofenceSSID(testSSID)
        let otherSSID = "other_wifi"
        viewModel.ssid.accept(otherSSID)
        viewModel.updateGeofenceCenter(CLLocationCoordinate2D(latitude: 0, longitude: 0))
        viewModel.userCurrentLocation.accept(CLLocationCoordinate2DMake(10.0, 10.0))
        viewModel.assessPositionRelativeToGeofence()
        XCTAssert(viewModel.position.value == .outside)
    }
    
    func testPositionWhenMatchingSSIDAndWithinBoundsOfGeofence() {
        let testSSID = "test_wifi"
        viewModel.updateGeofenceSSID(testSSID)
        viewModel.ssid.accept(testSSID)
        viewModel.updateGeofenceCenter(CLLocationCoordinate2D(latitude: 0, longitude: 0))
        viewModel.userCurrentLocation.accept(CLLocationCoordinate2DMake(0.0, 0.0))
        viewModel.assessPositionRelativeToGeofence()
        XCTAssert(viewModel.position.value == .inside)
    }
    
    func testPositionWhenNonMatchingSSIDAndWithinBoundsOfGeofence() {
        let testSSID = "test_wifi"
        viewModel.updateGeofenceSSID(testSSID)
        let otherSSID = "other_wifi"
        viewModel.ssid.accept(otherSSID)
        viewModel.updateGeofenceCenter(CLLocationCoordinate2D(latitude: 0, longitude: 0))
        viewModel.userCurrentLocation.accept(CLLocationCoordinate2DMake(0.0, 0.0))
        viewModel.assessPositionRelativeToGeofence()
        XCTAssert(viewModel.position.value == .inside)
    }
    
    func testPositionWhenSSIDNotEstablishedAndOutsideBoundsOfGeofence() {
        viewModel.updateGeofenceCenter(CLLocationCoordinate2D(latitude: 0, longitude: 0))
        viewModel.userCurrentLocation.accept(CLLocationCoordinate2DMake(10.0, 10.0))
        viewModel.assessPositionRelativeToGeofence()
        XCTAssert(viewModel.position.value == .outside)
    }
    
    func testPositionWhenSSIDNotEstablishedAndWithinBoundsOfGeofence() {
        viewModel.updateGeofenceCenter(CLLocationCoordinate2D(latitude: 0, longitude: 0))
        viewModel.userCurrentLocation.accept(CLLocationCoordinate2DMake(0.0, 0.0))
        viewModel.assessPositionRelativeToGeofence()
        XCTAssert(viewModel.position.value == .inside)
    }
    
    func testSetGeofenceRadiusCausingPositionToBeOutsideGeofence() {
        viewModel.userCurrentLocation.accept(CLLocationCoordinate2DMake(1, 1))
        viewModel.updateGeofenceCenter(CLLocationCoordinate2D(latitude: 0, longitude: 0))
        viewModel.updateGeofenceRadius(1)
        viewModel.assessPositionRelativeToGeofence()
        XCTAssert(viewModel.position.value == .outside)
    }
    
    func testSetGeofenceRadiusCausingPositionToBeInsideGeofence() {
        viewModel.userCurrentLocation.accept(CLLocationCoordinate2DMake(1, 1))
        viewModel.updateGeofenceCenter(CLLocationCoordinate2D(latitude: 0, longitude: 0))
        viewModel.updateGeofenceRadius(200)
        viewModel.assessPositionRelativeToGeofence()
        XCTAssert(viewModel.position.value == .inside)
    }
}
