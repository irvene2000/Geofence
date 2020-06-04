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
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var connectedWifiLabel: UILabel!
    @IBOutlet weak var geofenceWifiTextField: UITextField!
    @IBOutlet weak var geofenceRadiusTextField: UITextField!
    
    // MARK: Private
    
    private var viewModel: ViewModelType = ViewModel()
    private let kCellIdentifier = "Cell"
    private var disposeBag: DisposeBag!
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let newGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMap(gestureRecognizer:)))
        return newGestureRecognizer
    }()
    
    // MARK: - Initializer and Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupListeners()
    }
   
    // MARK: - Private API -
    // MARK: Setup Methods
    
    private func setupViews() {
        title = NSLocalizedString("viewcontroller.title", comment: "")
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.addGestureRecognizer(tapGestureRecognizer)
        
        stateLabel.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        stateLabel.layer.cornerRadius = 15.0
        stateLabel.layer.masksToBounds = true
        
        geofenceWifiTextField.layer.borderColor = UIColor.lightGray.cgColor
        geofenceWifiTextField.layer.borderWidth = 2.0
        let wifiPlaceholder = NSLocalizedString("viewcontroller.wifiplaceholder", comment: "Placeholder text for entering wifi ssid")
        geofenceWifiTextField.attributedPlaceholder = NSAttributedString(string: wifiPlaceholder, attributes: [.foregroundColor: UIColor.lightGray])
        geofenceWifiTextField.delegate = self
        
        geofenceRadiusTextField.layer.borderColor = UIColor.lightGray.cgColor
        geofenceRadiusTextField.layer.borderWidth = 2.0
        let radiusPlaceholder = NSLocalizedString("viewcontroller.geofenceradiusplaceholder", comment: "Placeholder text for entering radius of geofence")
        geofenceRadiusTextField.keyboardType = .numberPad
        geofenceRadiusTextField.attributedPlaceholder = NSAttributedString(string: radiusPlaceholder, attributes: [.foregroundColor: UIColor.lightGray])
        geofenceRadiusTextField.delegate = self
        
        addGeofenceOverlay()
    }
    
    private func setupListeners() {
        disposeBag = DisposeBag()
        
        viewModel.geofenceCenter
            .subscribe(onNext: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.addGeofenceOverlay()
                strongSelf.centerMap()
                
                strongSelf.viewModel.assessPositionRelativeToGeofence()
            })
            .disposed(by: disposeBag)
        
        viewModel.geofenceRadius
            .subscribe(onNext: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.addGeofenceOverlay()
                strongSelf.centerMap()
                
                strongSelf.viewModel.assessPositionRelativeToGeofence()
            })
            .disposed(by: disposeBag)
        
        viewModel.ssid
            .subscribe(onNext: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                if let value = value {
                    strongSelf.connectedWifiLabel.text = String.localizedStringWithFormat(NSLocalizedString("viewcontroller.connected", comment: ""), value)
                }
                else {
                    strongSelf.connectedWifiLabel.text = String.localizedStringWithFormat(NSLocalizedString("viewcontroller.connected", comment: ""), "N/A")
                }
                
                strongSelf.viewModel.assessPositionRelativeToGeofence()
            })
        .disposed(by: disposeBag)
        
        viewModel.geofenceSSID
            .subscribe(onNext: { [weak self] (value) in
                guard let strongSelf = self else { return }
                
                strongSelf.viewModel.assessPositionRelativeToGeofence()
            })
            .disposed(by: disposeBag)
        
        viewModel.position
            .subscribe(onNext: { [weak self] (value) in
                guard let strongSelf = self else { return }
                switch value {
                case .undetermined:
                    strongSelf.stateLabel.text = NSLocalizedString("viewcontroller.undetermined", comment: "")
                case .inside:
                    strongSelf.stateLabel.text = NSLocalizedString("viewcontroller.inside", comment: "")
                case .outside:
                    strongSelf.stateLabel.text = NSLocalizedString("viewcontroller.outside", comment: "")
                }
                
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Convenience Methods
    
    private func addGeofenceOverlay() {
        mapView.removeOverlays(mapView.overlays)
        
        if let center = viewModel.geofenceCenter.value {
            mapView.addOverlay(MKPolygon.generateCircle(centeredOn: center, radius: viewModel.geofenceRadius.value))
        }
    }
    
    private func centerMap() {
        guard let center = viewModel.geofenceCenter.value else { return }
        
        let distance = viewModel.geofenceRadius.value / 50
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: distance, longitudeDelta: distance))
        mapView.setRegion(region, animated: true)
    }
    
    @objc private func didTapMap(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
        
        if gestureRecognizer.state == .ended {
            let locationInView = gestureRecognizer.location(in: mapView)
            let tappedCoordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
            viewModel.geofenceCenter.accept(tappedCoordinate)
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

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        
        if textField == geofenceRadiusTextField {
            return newString?.range(of: "^[0-9]{0,3}$", options: .regularExpression) != nil
        }
        else {
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == geofenceRadiusTextField {
            guard let newRadius = Double(textField.text ?? "0") else { return }
            viewModel.geofenceRadius.accept(newRadius)
        }
        else if textField == geofenceWifiTextField {
            viewModel.geofenceSSID.accept(textField.text)
        }
    }
}
