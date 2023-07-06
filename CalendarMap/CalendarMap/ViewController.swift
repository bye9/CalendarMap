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
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var mainMapView: NMFMapView!
    @IBOutlet weak var searchLocalTextField: UITextField!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    @IBOutlet weak var periodShadowView: UIView!
    @IBOutlet weak var periodButton: UIButton!
    
    @IBOutlet weak var calendarImageView: UIImageView!
    @IBOutlet weak var calendarShadowView: UIView!
    @IBOutlet weak var calendarButton: UIButton!
    

    @IBOutlet weak var currentLocationShadowView: UIView!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    var floatingPanel: FloatingPanelController!
    var mapViewModel = MapViewModel()
    var searchViewModel = SearchViewModel()
    let infoWindow = NMFInfoWindow()
    let locationManager = CLLocationManager()
    var currentIdx: CGFloat = 0.0
    
    // TODO: 대화역, 상암중학교, 부산역 좌표 이동 테스트
    var coordinates: [(Double, Double)] = [(126.747500970967, 37.676157377075), (126.888144865456, 37.5790897397893), (129.04141918283216, 35.11510918247538)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    func setupViews() {
        initView()
        initMapSetting()
        initFloatingPanel()
        initMainCollectionView()
    }
    
    /// 나머지 뷰 그림자 및 테두리 설정
    func initView() {
        searchView.layer.cornerRadius = 2
        searchView.layer.shadowColor = AppStyles.Color.Shadow.cgColor
        searchView.layer.shadowOpacity = 0.3
        searchView.layer.shadowOffset = CGSize.zero
        searchView.layer.shadowRadius = 14
        searchView.translatesAutoresizingMaskIntoConstraints = false
        
        searchLocalTextField.delegate = self
        searchLocalTextField.attributedPlaceholder = NSAttributedString(string: "어디서 만나세요?", attributes: [
            .font: AppStyles.Fonts.Body1!,
            .foregroundColor : AppStyles.Color.Gray6])
        
        periodShadowView.addSubview(periodButton)
        periodButton.layer.cornerRadius = 16
        periodButton.layer.masksToBounds = true
        periodShadowView.layer.shadowColor = AppStyles.Color.Shadow.cgColor
        periodShadowView.layer.shadowOpacity = 0.3
        periodShadowView.layer.shadowOffset = CGSize.zero
        periodShadowView.layer.shadowRadius = 14
        periodShadowView.layer.masksToBounds = false
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let periodEffect = UIVisualEffectView(effect: blurEffect)
        periodEffect.frame = self.periodButton.bounds
        self.periodButton.addSubview(periodEffect)

        calendarButton.layer.cornerRadius = calendarButton.frame.width / 2
        calendarButton.layer.masksToBounds = true
        calendarButton.layer.borderWidth = 1
        calendarButton.layer.borderColor = AppStyles.Color.Gray3.cgColor
        calendarShadowView.layer.shadowColor = AppStyles.Color.Shadow.cgColor
        calendarShadowView.layer.shadowOpacity = 0.3
        calendarShadowView.layer.shadowOffset = CGSize.zero
        calendarShadowView.layer.shadowRadius = 14
        calendarShadowView.layer.masksToBounds = false
        let calendarEffect = UIVisualEffectView(effect: blurEffect)
        calendarEffect.frame = self.calendarButton.bounds
        self.calendarButton.addSubview(calendarEffect)
        self.calendarButton.addSubview(calendarImageView)
        
        
        
        currentLocationButton.backgroundColor = UIColor.white
        currentLocationButton.layer.cornerRadius = currentLocationButton.frame.width / 2
        currentLocationButton.layer.masksToBounds = true
        currentLocationButton.layer.borderWidth = 1
        currentLocationButton.layer.borderColor = AppStyles.Color.Gray3.cgColor
        currentLocationShadowView.backgroundColor = UIColor.clear
        currentLocationShadowView.layer.shadowColor = AppStyles.Color.Shadow.cgColor
        currentLocationShadowView.layer.shadowOpacity = 0.3
        currentLocationShadowView.layer.shadowOffset = CGSize(width: 0, height: 1)
        currentLocationShadowView.layer.shadowRadius = 14
        currentLocationShadowView.layer.masksToBounds = false
        currentLocationShadowView.addSubview(currentLocationButton)
        

        
        
    }
    
    /// 네이버 지도를 사용하기 위한 초기 설정
    func initMapSetting() {
        moveToCurrentLocation()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
//        locationManagerDidChangeAuthorization?(locationManager)
        
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                print("위치 서비스 On 상태")
                self.locationManager.startUpdatingLocation()
                
                let marker = NMFMarker()
                marker.position = NMGLatLng(lat: self.locationManager.location?.coordinate.latitude ?? 0, lng: self.locationManager.location?.coordinate.longitude ?? 0)
//                marker.mapView = self.mainMapView
            } else {
                print("위치 서비스 Off 상태")
            }
        }

        mainMapView.touchDelegate = self
    }
    
    /// FloatingPanelController(bottom sheet) 화면 설정
    func initFloatingPanel() {
        floatingPanel = FloatingPanelController()
        floatingPanel.changePanelStyle()
        floatingPanel.delegate = self
        floatingPanel.isRemovalInteractionEnabled = true
        floatingPanel.layout = MyFloatingPanelLayout()
    }
    
    /// 하단 Carousel view 초기 설정
    func initMainCollectionView() {
        let layout = mainCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: 308, height: 92)
        layout.minimumLineSpacing = 16
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.decelerationRate = .fast
        mainCollectionView.isPagingEnabled = false
    }
    
    /// 장소 검색 시, 올라오는 하단 Carousel view에 검색 결과 테이블 뷰 표시
    /// - Parameter items: 카카오 장소
    func reloadFloatingPanel(_ items: KakaoSearchLocation) {
        DispatchQueue.main.async {
            let contentVC = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "SearchTableViewController")
            self.floatingPanel.set(contentViewController: contentVC)
            let vc = contentVC as! SearchTableViewController
            vc.delegate = self
            vc.locations = items
            vc.tb.backgroundColor = .white
            self.floatingPanel.track(scrollView: vc.tb)
            self.floatingPanel.addPanel(toParent: self)
        }
    }
    
    /// 지도 카메라 현재 위치로 이동
    func moveToCurrentLocation() {
        moveMapViewCamera(locationManager.location?.coordinate.latitude ?? 0, locationManager.location?.coordinate.longitude ?? 0)
        mainMapView.positionMode = .normal
    }
    
    /// 지도 카메라 좌표로 이동
    /// - Parameters:
    ///   - lat: 위도(ex: 37.67615277418487)
    ///   - lng: 경도(ex: 126.7474436759949)
    func moveMapViewCamera(_ lat: Double, _ lng: Double) {
//        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: 37.5788596, lng: 126.8878807))
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
        cameraUpdate.animation = .easeIn
        mainMapView.moveCamera(cameraUpdate) { (isCancelled) in
            if isCancelled {
                print("카메라 이동 취소")
            } else {
                print("카메라 이동 완료")
            }
        }
    }
    
    // TODO: delegate로 좌표받아서 카메라 이동 함수 구현
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
        // 오버레이 닫기
        infoWindow.close()
        
        // FloatingPanelController(bottom sheet) 화면 닫기
        floatingPanel.removePanelFromParent(animated: true)
        
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

        searchViewModel.fetchKakaoSearchLocation(searchWord: word, lng: String(locationManager.location?.coordinate.longitude ?? 0), lat: String(locationManager.location?.coordinate.latitude ?? 0) ) { data in
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

extension ViewController: SendCoordinateDelegate {
    
    func sendCoordinate(x: String, y: String) {
//        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchTableViewController") as? SearchTableViewController else { return }
//        vc.delegate = self
        
        DispatchQueue.main.async {
            // bottom panel 닫기
//            self.floatingPanel.removePanelFromParent(animated: true)
            
            self.moveMapViewCamera(Double(y) ?? 0, Double(x) ?? 0)
            
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: Double(y) ?? 0, lng: Double(x) ?? 0)
            marker.mapView = self.mainMapView
        }
    }
    
    // TODO: 일정 등록하기 화면으로 이동
    func registerSchedule() {
//        self.floatingPanel.removePanelFromParent(animated: true)
//
//
//        guard let vc = UIStoryboard(name: "Schedule", bundle: nil).instantiateViewController(withIdentifier: "RegisterScheduleViewController") as? RegisterScheduleViewController else { return }
//
//        self.navigationController?.pushViewController(vc, animated: true)
        

    }
    
    
}

extension FloatingPanelController {
    func changePanelStyle() {
        let appearance = SurfaceAppearance()
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: -4)
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

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScheduleCollectionViewCell", for: indexPath) as? ScheduleCollectionViewCell else { return UICollectionViewCell() }
        
    
        cell.layer.cornerRadius = 5
        cell.layer.shadowColor = AppStyles.Color.Shadow.cgColor
        cell.layer.shadowOpacity = 0.3
        cell.layer.shadowOffset = CGSize.zero
        cell.layer.shadowRadius = 14
        cell.translatesAutoresizingMaskIntoConstraints = false
        
        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let layout = self.mainCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let cellWidth = layout.itemSize.width + layout.minimumLineSpacing
        var offset = targetContentOffset.pointee
        let index = round((offset.x + mainCollectionView.contentInset.left) / cellWidth)
        
        if index > currentIdx {
            currentIdx += 1
        } else if index < currentIdx {
            if currentIdx != 0 {
                currentIdx -= 1
            }
        }
        offset = CGPoint(x: currentIdx * cellWidth - mainCollectionView.contentInset.left, y: 0)
        targetContentOffset.pointee = offset
        
        let marker = NMFMarker()
//        marker.position = NMGLatLng(lat: locationManager.location?.coordinate.latitude ?? 0, lng: locationManager.location?.coordinate.longitude ?? 0)
        marker.position = NMGLatLng(lat: coordinates[Int(currentIdx)].1, lng: coordinates[Int(currentIdx)].0)
        marker.mapView = self.mainMapView
        marker.iconImage = NMFOverlayImage(name: "scheduleCircleIconRed")
        marker.captionAligns = [NMFAlignType.center]
        
        let infoWindow = NMFInfoWindow()
        let dataSource = CustomInfoWindowDataSource()
        infoWindow.dataSource = dataSource
        infoWindow.open(with: marker, alignType: .center)
        infoWindow.offsetY = 6
        
        moveMapViewCamera(coordinates[Int(currentIdx)].1, coordinates[Int(currentIdx)].0)
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
            .full: FloatingPanelLayoutAnchor(absoluteInset: 126, edge: .top, referenceGuide: .superview),
            .half: FloatingPanelLayoutAnchor(absoluteInset: 312, edge: .bottom, referenceGuide: .superview),
        ]
    }
}

