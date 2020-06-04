//
//  MKPolygon+Circle.swift
//  Geofence
//
//  Created by Tan Way Loon on 04/06/2020.
//  Copyright © 2020 Tan Way Loon. All rights reserved.
//

import Foundation
import MapKit

// Code to get circle coordinates from here https://stackoverflow.com/questions/55394730/inverted-circle-map-fill-in-swift-4
extension MKPolygon {
    class func makeCircleCoordinates(_ coordinate: CLLocationCoordinate2D, radius: Double, tolerance: Double = 3.0) -> [CLLocationCoordinate2D] {
        let latRadian = coordinate.latitude * .pi / 180
        let lngRadian = coordinate.longitude * .pi / 180
        let distance = (radius) / 6371 // kms
        return stride(from: 0.0, to: 360.0, by: tolerance).map {
            let bearing = $0 * .pi / 180
            
            let lat2 = asin(sin(latRadian) * cos(distance) + cos(latRadian) * sin(distance) * cos(bearing))
            var lon2 = lngRadian + atan2(sin(bearing) * sin(distance) * cos(latRadian),cos(distance) - sin(latRadian) * sin(lat2))
            lon2 = fmod(lon2 + 3 * .pi, 2 * .pi) - .pi  // normalise to -180..+180º
            return CLLocationCoordinate2D(latitude: lat2 * (180.0 / .pi), longitude: lon2 * (180.0 / .pi))
        }
    }
    
    class func generateCircle(centeredOn center: CLLocationCoordinate2D, radius: Double) -> MKPolygon {
        let circleCoordinates = makeCircleCoordinates(center, radius: radius)
        let polygon1 = MKPolygon(coordinates: circleCoordinates, count: circleCoordinates.count, interiorPolygons: nil)
        return polygon1
    }
}
