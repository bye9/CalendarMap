//
//  ViewController.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/02/21.
//

import UIKit
import NMapsMap
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var mainMapView: NMFMapView!
    
    var mapViewModel = MapViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
                
        if CLLocationManager.locationServicesEnabled() {
            print("위치 서비스 On 상태")
            locationManager.startUpdatingLocation()
            print(locationManager.location?.coordinate)
            
            
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: locationManager.location?.coordinate.latitude ?? 0, lng: locationManager.location?.coordinate.longitude ?? 0)
            marker.mapView = mainMapView
            
        } else {
            print("위치 서비스 Off 상태")
        }
        
        mainMapView.touchDelegate = self
    }
    
    
    @IBAction func currentLocationTapped(_ sender: UIButton) {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: locationManager.location?.coordinate.latitude ?? 0, lng: locationManager.location?.coordinate.longitude ?? 0))
        
        cameraUpdate.animation = .easeIn
        mainMapView.moveCamera(cameraUpdate)
        
    }
    


}

extension ViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        let coords = "\(latlng.lng),\(latlng.lat)"
        
        print(coords)
        
        
        mapViewModel.fetchCoords(coords: coords) { data in
            dump(data)
        }
        
    }
}
