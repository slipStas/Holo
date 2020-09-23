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
        let camera = GMSCameraPosition.camera(withTarget: coordinateMoscovCenter, zoom: 16)
        mapView.camera = camera
        mapView.isTrafficEnabled = true
        mapView.mapType = .normal
    }
    func addMarker() {
        let marker = GMSMarker(position: coordinateMoscovCenter)
        let rect = CGRect(x: 0, y: 0, width: 60, height: 60)
        let markerView = UIView(frame: rect)
        
        markerView.backgroundColor = .cyan
        markerView.layer.cornerRadius = markerView.frame.height / 2
        markerView.layer.masksToBounds = false
        markerView.clipsToBounds = false
        markerView.layer.shadowRadius = 30
        markerView.layer.shadowColor = UIColor.black.cgColor
        markerView.layer.shadowOpacity = 1

        marker.map = mapView
        marker.iconView = markerView
        marker.title = "Title"
        marker.snippet = "This is the center of the world"
        self.marker = marker
    }
    func removeMarker() {
        self.marker?.map = nil
        self.marker = nil
    }
}
