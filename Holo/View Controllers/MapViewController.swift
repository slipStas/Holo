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
    var marker: GMSMarker?
    var manualMarker: GMSMarker?
    var locationManager: CLLocationManager?
    var isUpdateLocation = false
    var backgroundTimer: Timer?
    var backgroundTimerCount = 0.0 {
        didSet {
            print(backgroundTimerCount)
        }
    }
    var beginBackgroundTimerTask: UIBackgroundTaskIdentifier?
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    var idCounter: Int64 = 0
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var showAllRoutesButton: UIBarButtonItem!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var clearRoutsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { (notification) in
            print("app did enter to background")
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { (notification) in
            print("app will enter foreground")
        }
        coordinates = [CoordinatesCoreData(context: self.context)]
        
        configureMap()
        configureLocationManager()
        configureBackgroundTask()
        backgroundTimerCount = 0.0
        setupLogOutButton()
    }
    
    @IBAction func trackingLocation(_ sender: UIBarButtonItem) {
        
        if coordinates!.count > 0 {
            coordinates?.remove(at: 0)
        }
        routePath?.removeAllCoordinates()
        
        if !isUpdateLocation {
            startBackgroundTimer()
            mapView.animate(toZoom: 16)
            showAllRoutesButton.isEnabled = false
            clearRoutsButton.isEnabled = false
            routeCoreData = Route(context: self.context)

            locationManager?.startUpdatingLocation()
            sender.title = "Stop tracking"
            self.isUpdateLocation = true
        } else {
            showAllRoutesButton.isEnabled = true
            clearRoutsButton.isEnabled = true
            locationManager?.stopUpdatingLocation()
            sender.title = "Start tracking"
            self.isUpdateLocation = false
            self.mapView.animate(toBearing: .zero)
            routeCoreData?.time = backgroundTimerCount
            routeCoreData?.date = Date()
            coordinates?.forEach({ (coord) in
                routeCoreData?.routeLength += (coord.speed * 1000 * 1.609 / 60 / 60)
            })
            coordinates?.forEach {$0.route = routeCoreData}
            
            do {
                try self.context.save()
                idCounter = 0
                print("save data")
            } catch let error {
                print(error.localizedDescription)
            }
            stopBackgroundTimer()
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
                self.transmittionRoute?.coordinates?.forEach {print($0)}
            }
        }
        if transmittionRoute != nil {
            
            guard let coordinates = (transmittionRoute?.coordinates?.allObjects as? [CoordinatesCoreData]) else {return}
            var cllCoordinates: [CLLocationCoordinate2D] = []
            coordinates.sorted {$0.index < $1.index}.forEach {cllCoordinates.append(CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude))}            
            
            if cllCoordinates.count > 0 {
                var bounds = GMSCoordinateBounds()
                cllCoordinates.forEach { (location) in
                    bounds = bounds.includingCoordinate(location)
                }
                let camera = mapView.camera(for: bounds, insets: UIEdgeInsets())!
                mapView.camera = camera
                mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30))
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

    @IBAction func logOut(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
        defaults.set(false, forKey: "isLogin")
        print("go to LoginViewController")
    }
    
    @IBAction func clearRoute(_ sender: Any) {
        mapView.clear()
        configureLocationManager()
    }
    
    func configureMap() {
        
        let camera = GMSCameraPosition()

        mapView.camera = camera
        mapView.animate(toZoom: 16)
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
            self?.backgroundTimerCount += 1
        })
    }
    
    func stopBackgroundTimer() {
        self.backgroundTimer?.invalidate()
        self.backgroundTimer = nil
        self.backgroundTimerCount = 0
        print("stop timer")
    }
    
    func setupLogOutButton() {

        logOutButton.setTitle("Log out", for: .normal)
        logOutButton.layer.cornerRadius = self.logOutButton.frame.height / 3
        logOutButton.layer.masksToBounds = true
        logOutButton.layer.borderWidth = 1
        logOutButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        clearRoutsButton.setTitle("Clear rout", for: .normal)
        clearRoutsButton.layer.cornerRadius = self.logOutButton.frame.height / 3
        clearRoutsButton.layer.masksToBounds = true
        clearRoutsButton.layer.borderWidth = 1
        clearRoutsButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
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
        mapView.animate(toLocation: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
        let newCoordinates = CoordinatesCoreData(context: self.context)
        
        if isUpdateLocation {
            mapView.animate(toLocation: location.coordinate)
            mapView.animate(toBearing: location.course)
            
            newCoordinates.latitude = location.coordinate.latitude
            newCoordinates.longitude = location.coordinate.longitude
            newCoordinates.speed = location.speed
            newCoordinates.index = idCounter
            
            coordinates?.append(newCoordinates)
            
            routePath?.add(location.coordinate)
            route?.path = routePath
            route?.strokeWidth = 5
            route?.strokeColor = .orange
            idCounter += 1
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
