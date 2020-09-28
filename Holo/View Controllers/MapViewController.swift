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

    var transmittionRoute: Route?
    var coordinates: [CoordinatesCoreData]?
    var routeCoreData: Route?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let fiveMinutes = 5 * 60
//    let coordinateMoscovCenter = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
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
        coordinates = [CoordinatesCoreData(context: self.context)]
        
        configureMap()
        configureLocationManager()
        configureBackgroundTask()
        backgroundTimerCount = fiveMinutes
    }
    
    @IBAction func trackingLocation(_ sender: UIBarButtonItem) {
        
        coordinates?.remove(at: 0)
        if !isUpdateLocation {
            routeCoreData = Route(context: self.context)

            locationManager?.startUpdatingLocation()
            sender.title = "Stop tracking"
            self.isUpdateLocation = true
        } else {
            locationManager?.stopUpdatingLocation()
            sender.title = "Start tracking"
            self.isUpdateLocation = false
            self.mapView.animate(toBearing: .zero)
            routeCoreData?.time = "date"
            routeCoreData?.routeLength = 12.12
            coordinates?.forEach {$0.route = routeCoreData}
//            coordinates?.forEach {print($0.latitude)}
            
            do {
                try self.context.save()
                print(routeCoreData?.coordinates?.count ?? 0)
                print("save data")
            } catch let error {
                print(error.localizedDescription)
            }
            
            routeCoreData = nil
            coordinates?.removeAll()
        }
    }
    
    
    @IBAction func addRoute(segue: UIStoryboardSegue) {
        if segue.identifier == "addRout" {
            let pathesVC = segue.source as! PathesViewController
            if let indexPath = pathesVC.pathesTableView.indexPathForSelectedRow {
                let route = pathesVC.routsArray[indexPath.row]
                self.transmittionRoute = route
            }
        }
        if transmittionRoute != nil {
            
            guard let coordinates = (transmittionRoute?.coordinates?.allObjects as? [CoordinatesCoreData]) else {return}
            var cllCoordinates: [CLLocationCoordinate2D] = []
            coordinates.forEach {cllCoordinates.append(CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude))}
            
            if cllCoordinates.count > 0 {
                let bounds = GMSCoordinateBounds(coordinate: cllCoordinates.first!, coordinate: cllCoordinates.last!)
                let camera = mapView.camera(for: bounds, insets: UIEdgeInsets())!
                mapView.camera = camera
            }
            
            routePath?.removeAllCoordinates()
            
            cllCoordinates.forEach { (coordinate) in
                print(coordinate)
                routePath?.add(coordinate)
                route?.path = routePath
            }
            route?.strokeWidth = 5
            route?.strokeColor = .orange
            route?.map = mapView
        }
    }

    
    func configureMap() {
        
        let camera = GMSCameraPosition()

        mapView.camera = camera
        mapView.animate(toZoom: 15)
//        mapView.isTrafficEnabled = true
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
                
        guard let location = locations.first else {return}
        print(location.coordinate)
        mapView.animate(toLocation: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
        let newCoordinates = CoordinatesCoreData(context: self.context)
        
        if isUpdateLocation {
            mapView.animate(toLocation: location.coordinate)
            mapView.animate(toBearing: location.course)
            
            newCoordinates.latitude = location.coordinate.latitude
            newCoordinates.longitude = location.coordinate.longitude
            
            coordinates?.append(newCoordinates)
            
            routePath?.add(location.coordinate)
            route?.path = routePath
            route?.strokeWidth = 5
            route?.strokeColor = .orange
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
