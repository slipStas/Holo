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

    var coordinatesArray: [CoordinatesCoreData] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let fiveMinutes = 5 * 60
    let coordinateMoscovCenter = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
    var marker: GMSMarker?
    var manualMarker: GMSMarker?
    var locationManager: CLLocationManager?
    var isUpdateLocation = false
    var backgroundTimer: Timer?
    var backgroundTimerCount = 0 {
        didSet {
            print(backgroundTimerCount)
        }
    }
    var beginBackgroundTimerTask: UIBackgroundTaskIdentifier?
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { (notification) in
            self.startBackgroundTimer()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { (notification) in
            self.stopBackgroundTimer()
        }
        
        configureMap()
        configureLocationManager()
        configureBackgroundTask()
        backgroundTimerCount = fiveMinutes
        
        
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
            do {
                try self.context.save()
                print("save data")
            } catch {
                
            }
        }
    }
    
    func configureMap() {
        
        let camera = GMSCameraPosition.camera(withTarget: coordinateMoscovCenter, zoom: 17)

        mapView.camera = camera
        mapView.isTrafficEnabled = true
        mapView.mapType = .normal
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        
        mapView.delegate = self
    }
    
    func configureLocationManager() {
        route?.map = nil
        route = GMSPolyline()
        routePath = GMSMutablePath()
        route?.map = mapView
        
        locationManager = CLLocationManager()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.startMonitoringSignificantLocationChanges()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestAlwaysAuthorization()
    }
    
    func configureBackgroundTask() {
        beginBackgroundTimerTask = UIApplication.shared.beginBackgroundTask(expirationHandler: { [weak self] in
            guard let strongSelf = self else {return}
            
            UIApplication.shared.endBackgroundTask(strongSelf.beginBackgroundTimerTask!)
            strongSelf.beginBackgroundTimerTask = UIBackgroundTaskIdentifier.invalid
        })
    }
    
    func startBackgroundTimer() {
        print("start timer")
        
        backgroundTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_) in
            switch self?.backgroundTimerCount {
            case 0:
                self?.backgroundTimer?.invalidate()
                self?.backgroundTimer = nil
                UIApplication.shared.endBackgroundTask((self?.beginBackgroundTimerTask)!)
                self?.beginBackgroundTimerTask = UIBackgroundTaskIdentifier.invalid
            default:
                self?.backgroundTimerCount -= 1
            }
        })
    }
    
    func stopBackgroundTimer() {
        self.backgroundTimer?.invalidate()
        self.backgroundTimer = nil
        self.backgroundTimerCount = fiveMinutes
        print("stop timer")
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
        
        locations.forEach {print($0.coordinate)}
        
        guard let coordinates = locations.first else {return}
        
        mapView.animate(toLocation: coordinates.coordinate)
        mapView.animate(toBearing: coordinates.course)
        
        let newCoordinateArray = CoordinatesCoreData(context: self.context)
        newCoordinateArray.latitude = coordinates.coordinate.latitude
        newCoordinateArray.longitude = coordinates.coordinate.longitude
        self.coordinatesArray.append(newCoordinateArray)
        
        routePath?.add(coordinates.coordinate)
        route?.path = routePath
        route?.strokeWidth = 5
        route?.strokeColor = .orange
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        print("===========================")
    }
}
