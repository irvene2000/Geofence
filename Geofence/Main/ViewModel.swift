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

protocol ViewModelType {
    var geofenceCenter: BehaviorRelay<CLLocationCoordinate2D?> { get }
    var geofenceRadius: BehaviorRelay<Double?> { get }
}

class ViewModel: ViewModelType {
    var geofenceCenter: BehaviorRelay<CLLocationCoordinate2D?> = BehaviorRelay(value: nil)
    var geofenceRadius: BehaviorRelay<Double?> = BehaviorRelay(value: nil)
}
