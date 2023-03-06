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
    @IBOutlet var searchLocalTextField: UITextField!
    
    var mapViewModel = MapViewModel()
    var searchViewModel = SaerchViewModel()
    let infoWindow = NMFInfoWindow()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchLocalTextField.delegate = self
        initMapSetting()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    func initMapSetting() {
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

        moveToCurrentLocation()
    }
    
    func moveToCurrentLocation() {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: locationManager.location?.coordinate.latitude ?? 0, lng: locationManager.location?.coordinate.longitude ?? 0))
        
        cameraUpdate.animation = .easeIn
        mainMapView.moveCamera(cameraUpdate)
        mainMapView.positionMode = .direction
    }
    
    
    
    @IBAction func currentLocationTapped(_ sender: UIButton) {
        moveToCurrentLocation()
        
        
    }
    
    
}
    
    
extension ViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        infoWindow.close()
        
        
        let coords = "\(latlng.lng),\(latlng.lat)"
        print(coords)

        mapViewModel.fetchAddress(coords: coords) { data in
            dump(data)
        }
        
    }
    
    
    /// 지도 심벌이 탭되면 호출되는 콜백 메서드.
    /// - Parameters:
    ///   - mapView: 지도객체
    ///   - symbol: 탭된 심벌
    /// - Returns: YES일 경우 이벤트를 소비합니다. 그렇지 않을 경우 이벤트가 지도로 전달되어 mapView:didTapMap:point:가 호출됩니다.
    func mapView(_ mapView: NMFMapView, didTap symbol: NMFSymbol) -> Bool {
        dump(mapView)
        dump(symbol)
        //        <NMFSymbol:position=<NMGLatLng: 37.67111706221642,126.7377662658691>, caption=대화동 레포츠공원>
        

        let dataSource = NMFInfoWindowDefaultTextSource.data()
        dataSource.title = symbol.caption
        infoWindow.dataSource = dataSource
        infoWindow.position = NMGLatLng(lat: symbol.position.lat, lng: symbol.position.lng)
        infoWindow.open(with: mainMapView)
        
        
        
        
        return true
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let word = textField.text else { return false }
        
        searchViewModel.fetchSearchLocal(searchWord: word) { data in
            dump(data)
            
        }
        
        self.searchLocalTextField.resignFirstResponder()
        
        return true
    }
}

