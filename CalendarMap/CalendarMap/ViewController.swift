//
//  ViewController.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/02/21.
//

import UIKit
import NMapsMap
import CoreLocation
import FloatingPanel

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var fpc: FloatingPanelController!
    
    @IBOutlet var mainMapView: NMFMapView!
    @IBOutlet var searchLocalTextField: UITextField!
    
    var mapViewModel = MapViewModel()
    var searchViewModel = SearchViewModel()
    let infoWindow = NMFInfoWindow()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchLocalTextField.delegate = self
        initMapSetting()
        initFloatingPanel()
    }
    
    private func initFloatingPanel() {
        fpc = FloatingPanelController()
        fpc.changePanelStyle()
        fpc.delegate = self
        fpc.isRemovalInteractionEnabled = true
        fpc.layout = MyFloatingPanelLayout()
    }
    
    private func reloadFloatingPanel(_ items: SearchLocation) {
        DispatchQueue.main.async {
            let contentVC = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "SearchTableViewController")
            self.fpc.set(contentViewController: contentVC)
            let vc = contentVC as! SearchTableViewController
            vc.locations = items
            self.fpc.track(scrollView: vc.tb)
            self.fpc.addPanel(toParent: self)
        }

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    func initMapSetting() {
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
//        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: locationManager.location?.coordinate.latitude ?? 0, lng: locationManager.location?.coordinate.longitude ?? 0))
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: 37.578325, lng: 126.8946875))
        cameraUpdate.animation = .easeIn
        mainMapView.moveCamera(cameraUpdate)
        mainMapView.positionMode = .direction
    }
    
    
    
    @IBAction func currentLocationTapped(_ sender: UIButton) {
        moveToCurrentLocation()
        
        
    }
    
    
}
    
    
extension ViewController: NMFMapViewTouchDelegate {
    
    /// 지도가 탭되면 호출되는 콜백 메서드.
    /// - Parameters:
    ///   - mapView: 지도객체
    ///   - latlng: 탭된 지점의 지도 좌표
    ///   - point: 탭된 지점의 화면 좌표
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        // 심볼 닫기
        infoWindow.close()
        
        // bottom panel 닫기
        fpc.removePanelFromParent(animated: true)
        
        let coords = "\(latlng.lng),\(latlng.lat)"
        print(coords)

        mapViewModel.fetchAddress(coords: coords) { data in
//            dump(data)
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
        self.searchLocalTextField.resignFirstResponder()
        
        guard let word = textField.text else { return false }


        
        searchViewModel.fetchSearchLocal(searchWord: word) { data in
            dump(data)
            
            guard let items = data else { return }
            self.reloadFloatingPanel(items)
            
            
        }
        
        return true
    }
}

extension ViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidMove(_ fpc: FloatingPanelController) {
        if fpc.state == .full {
            
        } else {
            
        }
    }
}

extension FloatingPanelController {
    func changePanelStyle() {
        let appearance = SurfaceAppearance()
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: -10)
        shadow.radius = 2
        shadow.opacity = 0.15
        appearance.shadows = [shadow]
        appearance.cornerRadius = 15.0
        appearance.backgroundColor = .clear
        appearance.borderColor = .clear
        appearance.borderWidth = 0
        
        surfaceView.grabberHandle.isHidden = true
        surfaceView.appearance = appearance
    }
}

class MyFloatingPanelLayout: FloatingPanelLayout {
    var position: FloatingPanelPosition {
        return .bottom
    }

    var initialState: FloatingPanelState {
        return .half
    }

    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 40.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(absoluteInset: 200, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
}
