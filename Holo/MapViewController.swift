//
//  MapViewController.swift
//  Holo
//
//  Created by Stanislav Slipchenko on 23.09.2020.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {

    let coordinateMoscovCenter = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
    var marker: GMSMarker?
    var manualMarker: GMSMarker?
    var locationManager: CLLocationManager?
    var isUpdateLocation = false
    
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureMap()
        configureLocationManager()
    }
    
    @IBAction func trackingLocation(_ sender: UIBarButtonItem) {
        if !isUpdateLocation {
            locationManager?.startUpdatingLocation()
            sender.title = "Stop tracking"
            self.isUpdateLocation = true
        } else {
            locationManager?.stopUpdatingLocation()
            sender.title = "Start tracking"
            self.isUpdateLocation = false
            self.mapView.animate(toBearing: .zero)
        }
    }
    
    func configureMap() {
        let camera = GMSCameraPosition.camera(withTarget: coordinateMoscovCenter, zoom: 16)
        mapView.camera = camera
        mapView.isTrafficEnabled = true
        mapView.mapType = .normal
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        
        mapView.delegate = self
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
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        self.marker = marker
    }
    func removeMarker() {
        self.marker?.map = nil
        self.marker = nil
    }
    
    func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.delegate = self
    }
}

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print(coordinate)
        
        if let manualMarker = manualMarker {
            manualMarker.position = coordinate
        } else {
            let marker = GMSMarker(position: coordinate)
            marker.map = mapView
            self.manualMarker = marker
        }
    }
}
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.first as Any)
        
        guard let coordinates = locations.first else {return}
        
        mapView.animate(toLocation: coordinates.coordinate)
        mapView.animate(toBearing: coordinates.course)
        let marker = GMSMarker(position: coordinates.coordinate)
        let rect = CGRect(x: 0, y: 0, width: 7, height: 7)
        let markerView = UIView(frame: rect)
        
        markerView.backgroundColor = .blue
        markerView.layer.cornerRadius = markerView.frame.height / 2
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.opacity = 0.5

        marker.map = mapView
        marker.iconView = markerView
        self.marker = marker
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
