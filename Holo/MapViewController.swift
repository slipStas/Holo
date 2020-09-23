//
//  MapViewController.swift
//  Holo
//
//  Created by Stanislav Slipchenko on 23.09.2020.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {

    let coordinateMoscovCenter = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
    var marker: GMSMarker?
    
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureMap()
    }
    
    @IBAction func toRedSquare(_ sender: Any) {
        mapView.animate(toLocation: coordinateMoscovCenter)
    }
    @IBAction func addMarker(_ sender: Any) {
        if marker == nil {
            addMarker()
        } else {
            removeMarker()
        }
        
    }
    
    func configureMap() {
        let camera = GMSCameraPosition.camera(withTarget: coordinateMoscovCenter, zoom: 12)
        mapView.camera = camera
        mapView.isTrafficEnabled = true
        mapView.mapType = .normal
    }
    func addMarker() {
        let marker = GMSMarker(position: coordinateMoscovCenter)
        marker.map = mapView
        marker.icon = GMSMarker.markerImage(with: .blue)
        self.marker = marker
    }
    func removeMarker() {
        self.marker?.map = nil
        self.marker = nil
    }
}
