//
//  SSIDViewModel.swift
//  Geofence
//
//  Created by Tan Way Loon on 04/06/2020.
//  Copyright © 2020 Tan Way Loon. All rights reserved.
//

import Foundation
import RxCocoa

protocol SSIDViewModelType {
    var ssidList: BehaviorRelay<[String]> { get }
}

class SSIDViewModel: SSIDViewModelType {
    var ssidList = BehaviorRelay<[String]>(value: [])
}
