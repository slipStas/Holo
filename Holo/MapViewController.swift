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
    
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureMap()
    }
    
    func configureMap() {
        let camera = GMSCameraPosition.camera(withTarget: coordinateMoscovCenter, zoom: 12)
        mapView.camera = camera
        mapView.mapType = .normal
    }
    @IBAction func toRedSquare(_ sender: Any) {
        mapView.animate(toLocation: coordinateMoscovCenter)
    }
}
