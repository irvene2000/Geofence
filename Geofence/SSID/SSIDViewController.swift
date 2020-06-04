//
//  SSIDViewController.swift
//  Geofence
//
//  Created by Tan Way Loon on 04/06/2020.
//  Copyright © 2020 Tan Way Loon. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork
import UIKit

class SSIDViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var viewModel: SSIDViewModelType = SSIDViewModel()
    private let kCellIdentifier = "Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupListeners()
    }
    
    private func setupViews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
    }
    
    private func setupListeners() {
        
    }
}

extension SSIDViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.ssidList.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath)
        
        let currentSSID = viewModel.ssidList.value[indexPath.row]
        cell.textLabel?.text = currentSSID
        
        return cell
    }
}
