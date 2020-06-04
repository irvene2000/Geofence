//
//  ViewController.swift
//  Geofence
//
//  Created by Tan Way Loon on 04/06/2020.
//  Copyright © 2020 Tan Way Loon. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    // MARK: - Properties -
    // MARK: Internal
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Private
    
    private var viewModel: ViewModelType = ViewModel()
    private let kCellIdentifier = "Cell"
    
    // MARK: - Initializer and Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupListeners()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

    private func setupViews() {
        title = NSLocalizedString("viewcontroller.title", comment: "")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        
        mapView.delegate = self
    }
    
    private func setupListeners() {
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath)
        
        if indexPath.row == 0 {
            cell.textLabel?.text = NSLocalizedString("viewcontroller.modifygeofence", comment: "Title of cell to modify geofence")
        }
        else if indexPath.row == 1 {
            cell.textLabel?.text = NSLocalizedString("viewcontroller.selectssid", comment: "Title of cell to select a SSID")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: "ModifyGeofence", sender: nil)
        }
        else if indexPath.row == 1 {
            performSegue(withIdentifier: "SelectSSID", sender: nil)
        }
    }
}

extension ViewController: MKMapViewDelegate {
   
}
