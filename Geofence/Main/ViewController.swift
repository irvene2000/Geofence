//
//  ViewController.swift
//  Geofence
//
//  Created by Tan Way Loon on 04/06/2020.
//  Copyright © 2020 Tan Way Loon. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
class ViewController: UIViewController {

    // MARK: - Properties -
    // MARK: Internal
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Private
    
    private var viewModel: ViewModelType = ViewModel()
    private let kCellIdentifier = "Cell"
    private var disposeBag: DisposeBag!
    
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

    // MARK: - Private API -
    // MARK: Setup Methods
    
    private func setupViews() {
        title = NSLocalizedString("viewcontroller.title", comment: "")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        
        mapView.delegate = self
        mapView.isUserInteractionEnabled = false
        
        addGeofenceOverlay()
    }
    
    private func setupListeners() {
        disposeBag = DisposeBag()
        
        viewModel.geofenceCenter
            .subscribe(onNext: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.addGeofenceOverlay()
                strongSelf.centerMap()
            })
            .disposed(by: disposeBag)
        
        viewModel.geofenceRadius
            .subscribe(onNext: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.addGeofenceOverlay()
                strongSelf.centerMap()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Convenience Methods
    
    private func addGeofenceOverlay() {
        mapView.removeOverlays(mapView.overlays)
        
        if let center = viewModel.geofenceCenter.value,
            let radius = viewModel.geofenceRadius.value {
            mapView.addOverlay(MKPolygon.generateCircle(centeredOn: center, radius: radius))
        }
    }
    
    private func centerMap() {
        guard let center = viewModel.geofenceCenter.value,
            let radius = viewModel.geofenceRadius.value else { return }
        
        let distance = (radius) / 50
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: distance, longitudeDelta: distance))
        mapView.setRegion(region, animated: true)
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
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolygonRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.yellow
        renderer.lineWidth = 5.0
        renderer.fillColor = UIColor.yellow.withAlphaComponent(0.1)
        return renderer
    }
}
