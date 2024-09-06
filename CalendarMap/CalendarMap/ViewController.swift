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
import RealmSwift

class ViewController: UIViewController, CLLocationManagerDelegate {
    let realm = try! Realm()
    var realmData: Results<ScheduleDetailInfo>!
    var searchMarker = NMFMarker()
    let locationMarker = NMFMarker()
    var searchFloatingPanel: FloatingPanelController!
    var mapViewModel = MapViewModel()
    var searchViewModel = SearchViewModel()
    var scheduleViewModel = ScheduleViewModel()
    let infoWindow = NMFInfoWindow()
    let locationManager = CLLocationManager()
    var currentIdx: CGFloat = 0.0
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var mainMapView: NMFMapView!
    @IBOutlet weak var searchLocalTextField: UITextField!
    @IBOutlet weak var periodShadowView: UIView!
    @IBOutlet weak var periodButton: UIButton!
    
    @IBOutlet weak var calendarShadowView: UIView!
    @IBOutlet weak var calendarButton: UIButton!

    @IBOutlet weak var currentLocationShadowView: UIView!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    @IBOutlet weak var noScheduleView: UIView!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    // TODO: 대화역, 상암중학교, 부산역 좌표 이동 테스트
    var coordinates: [(Double, Double)] = [(126.747500970967, 37.676157377075), (126.888144865456, 37.5790897397893), (129.04141918283216, 35.11510918247538)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getRealmData()
        setupViews()
    }

    func getRealmData() {
        let data = realm.objects(ScheduleDetailInfo.self)
        if data.count > 0 {
            // 오늘에 해당하는 일정만 가져오기
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.dateFormat = "yyyy.M.d"
            let newString = dateFormatter.string(from: Date()) + "."

            realmData = data.filter("startDate BEGINSWITH '\(newString)'")
            realmData = realmData.sorted(byKeyPath: "startDate", ascending: true)
            print(realmData!)
        } else {
            realmData = data
        }
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
        
        periodButton.backgroundColor = .white
        periodButton.layer.cornerRadius = 16
        periodButton.layer.masksToBounds = true
        periodButton.layer.borderWidth = 1
        periodButton.layer.borderColor = AppStyles.Color.Gray3.cgColor
        periodShadowView.layer.shadowColor = AppStyles.Color.Shadow.cgColor
        periodShadowView.layer.shadowOpacity = 0.3
        periodShadowView.layer.shadowOffset = CGSize(width: 0, height: 1)
        periodShadowView.layer.shadowRadius = 14
        periodShadowView.layer.masksToBounds = false
        periodShadowView.addSubview(periodButton)
        
        calendarButton.backgroundColor = .white
        calendarButton.layer.cornerRadius = calendarButton.frame.width / 2
        calendarButton.layer.masksToBounds = true
        calendarButton.layer.borderWidth = 1
        calendarButton.layer.borderColor = AppStyles.Color.Gray3.cgColor
        calendarShadowView.layer.shadowColor = AppStyles.Color.Shadow.cgColor
        calendarShadowView.layer.shadowOpacity = 0.3
        calendarShadowView.layer.shadowOffset = CGSize(width: 0, height: 1)
        calendarShadowView.layer.shadowRadius = 14
        calendarShadowView.layer.masksToBounds = false
        calendarShadowView.addSubview(calendarButton)
        
        currentLocationButton.backgroundColor = .white
        currentLocationButton.layer.cornerRadius = currentLocationButton.frame.width / 2
        currentLocationButton.layer.masksToBounds = true
        currentLocationButton.layer.borderWidth = 1
        currentLocationButton.layer.borderColor = AppStyles.Color.Gray3.cgColor
        currentLocationShadowView.layer.shadowColor = AppStyles.Color.Shadow.cgColor
        currentLocationShadowView.layer.shadowOpacity = 0.3
        currentLocationShadowView.layer.shadowOffset = CGSize(width: 0, height: 1)
        currentLocationShadowView.layer.shadowRadius = 14
        currentLocationShadowView.layer.masksToBounds = false
        currentLocationShadowView.addSubview(currentLocationButton)
    }
    
    /// 네이버 지도를 사용하기 위한 초기 설정
    func initMapSetting() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
//        locationManagerDidChangeAuthorization?(locationManager)
        
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                print("위치 서비스 On 상태")
                self.locationManager.startUpdatingLocation()
                self.moveToCurrentLocation()
            } else {
                print("위치 서비스 Off 상태")
            }
        }

        mainMapView.touchDelegate = self
    }
    
    /// FloatingPanelController(bottom sheet) 화면 설정
    func initFloatingPanel() {
        searchFloatingPanel = FloatingPanelController()
        searchFloatingPanel.changePanelStyle()
        searchFloatingPanel.delegate = self
        searchFloatingPanel.isRemovalInteractionEnabled = true
        searchFloatingPanel.layout = SearchFloatingPanelLayout()
        
    }
    
    /// 하단 Carousel view 초기 설정
    func initMainCollectionView() {
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.decelerationRate = .fast
        mainCollectionView.isPagingEnabled = false
        mainCollectionView.register(UINib(nibName: "ScheduleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ScheduleCollectionViewCell")

        let layout = mainCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 16
        mainCollectionView.collectionViewLayout = layout
    }
    
    /// 장소 검색 시, 올라오는 하단 Floating Panel에 검색 결과 테이블 뷰 표시
    /// - Parameter items: 카카오 장소
    func reloadFloatingPanel(_ items: KakaoSearchLocation) {
        DispatchQueue.main.async {
            let contentVC = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "SearchTableViewController")
            self.searchFloatingPanel.set(contentViewController: contentVC)
            let vc = contentVC as! SearchTableViewController
            vc.delegate = self
            vc.locations = items
            vc.tb.backgroundColor = .white
            self.searchFloatingPanel.track(scrollView: vc.tb)
            self.searchFloatingPanel.addPanel(toParent: self, animated: true)
        }
    }
    
    /// 지도 카메라 현재 위치로 이동
    func moveToCurrentLocation() {
        moveMapViewCamera(locationManager.location?.coordinate.latitude ?? 0, locationManager.location?.coordinate.longitude ?? 0)
        DispatchQueue.main.async {
            self.mainMapView.positionMode = .normal
        }
    }
    
    /// 지도 카메라 좌표로 이동
    /// - Parameters:
    ///   - lat: 위도(ex: 37.67615277418487)
    ///   - lng: 경도(ex: 126.7474436759949)
    func moveMapViewCamera(_ lat: Double, _ lng: Double) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
        cameraUpdate.animation = .easeIn
        DispatchQueue.main.async {
            self.mainMapView.moveCamera(cameraUpdate) { (isCancelled) in
                if isCancelled {
                    print("카메라 이동 취소")
                } else {
                    print("카메라 이동 완료")
                }
            }
        }
    }
    
    /// 빈 화면 터치 시, 키보드 내리기
    override  func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    /// 달력 버튼 클릭
    @IBAction func calendarButtonTapped(_ sender: UIButton) {
        guard let calendarViewController = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CalendarViewController") as? CalendarViewController else { return }
        
        self.navigationController?.pushViewController(calendarViewController, animated: true)
    }
    
    /// 현재 위치 버튼 클릭
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
        searchFloatingPanel.removePanelFromParent(animated: true)
        
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
    /// 장소 검색 엔터 이후
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchLocalTextField.resignFirstResponder()
        
        guard let word = textField.text else { return false }
        
        let currentCoordinate = (locationManager.location?.coordinate.longitude, locationManager.location?.coordinate.latitude)
        searchViewModel.fetchKakaoSearchLocation(searchWord: word, lng: String(currentCoordinate.0 ?? 0), lat: String(currentCoordinate.1 ?? 0) ) { data in
            dump(data)
            
            guard let items = data else { return }
            if items.documents.isEmpty {
                let dialog = UIAlertController(title: "알림", message: "검색된 결과가 없습니다.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: .default, handler: {(alert:UIAlertAction!)-> Void in})
                dialog.addAction(okAction)
                
                DispatchQueue.main.async {
                    self.present(dialog, animated:true, completion:nil)
                }
                
                return
            }
            
            self.reloadFloatingPanel(items)
        }
        
        return true
    }
}

extension ViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidMove(_ fpc: FloatingPanelController) {
//        if floatingPanel.isAttracting == false {
//            let loc = floatingPanel.surfaceLocation
//            let minY = floatingPanel.surfaceLocation(for: .full).y - 6.0
//            let maxY = floatingPanel.surfaceLocation(for: .half).y + 6.0
//            floatingPanel.surfaceLocation = CGPoint(x: loc.x, y: min(max(loc.y, minY), maxY))
//        }
    }
}

extension ViewController: SendCoordinateDelegate {
    func sendCoordinate(lat: String, lng: String) {
        DispatchQueue.main.async {
            self.mainCollectionView.reloadData()
            self.moveMapViewCamera(Double(lat) ?? 0, Double(lng) ?? 0)
           
            // 현재 위치 마커 추가
            self.searchMarker.iconImage = NMFOverlayImage(name: "img_current_place")
            self.searchMarker.width = 24
            self.searchMarker.height = 36
            self.searchMarker.position = NMGLatLng(lat: Double(lat) ?? 0, lng: Double(lng) ?? 0)
            self.searchMarker.mapView = self.mainMapView
        }
    }
    
    // 일정 추가 완료 이후
    func registerScheduleCompleted(lat: String, lng: String) {
        DispatchQueue.main.async {
            self.mainCollectionView.reloadData()
            self.searchFloatingPanel.removePanelFromParent(animated: true)
            self.moveMapViewCamera(Double(lat) ?? 0, Double(lng) ?? 0)
            
            self.scrollToLastCell()
        }
    }
}

extension FloatingPanelController {
    func changePanelStyle() {
        let appearance = SurfaceAppearance()
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: -2)
        shadow.radius = 10
        shadow.opacity = 0.08
        appearance.shadows = [shadow]
        appearance.cornerRadius = 10
        appearance.backgroundColor = .clear
        appearance.borderColor = .clear
        appearance.borderWidth = 0
        
        surfaceView.grabberHandle.isHidden = true
        surfaceView.appearance = appearance
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if realmData.count > 0 {
            noScheduleView.isHidden = true
            mainCollectionView.isHidden = false
        } else {
            noScheduleView.isHidden = false
            mainCollectionView.isHidden = true
        }

        return realmData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScheduleCollectionViewCell", for: indexPath) as? ScheduleCollectionViewCell else { return UICollectionViewCell() }
        let data = realmData[indexPath.row]
        cell.colorCircle.image = UIImage(named: data.color)
        cell.scheduleName.text = data.scheduleTitle
        
        let startArray = data.startDate.components(separatedBy: " ")
        let startTime = "\(startArray[1]) \(startArray[2])"
        
        let endArray = data.endDate.components(separatedBy: " ")
        let endTime = "\(endArray[1]) \(endArray[2])"
        
        cell.scheduleTime.text = "\(startTime) - \(endTime)"
        cell.schedulePlace.text = data.locationName
        
        if realmData.count == 1 {
            setLocationMarker(0)
            // 일정 상세보기 데이터 세팅
            scheduleViewModel.scheduleSelected(data.scheduleTitle, data.startDate, data.endDate, data.locationName)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let scheduleDetailViewController = UIStoryboard(name: "Schedule", bundle: .main).instantiateViewController(withIdentifier: "ScheduleDetailViewController") as? ScheduleDetailViewController else { return }
        
        // 일정 상세보기 데이터 세팅
        let currentData = realmData[Int(currentIdx)]
        scheduleViewModel.scheduleSelected(currentData.scheduleTitle, currentData.startDate, currentData.endDate, currentData.locationName)
        
        scheduleDetailViewController.viewModel = scheduleViewModel
        self.present(scheduleDetailViewController, animated: true)
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
        
        // 검색해서 선택한 장소의 위치 마커 지우기
        self.searchMarker.mapView = nil
        
        // 이전 장소 위치 마커 지우기
        self.locationMarker.mapView = nil
        
        setLocationMarker(Int(currentIdx))
    }
    
    // 마지막 셀로 이동
    func scrollToLastCell() {
        guard let layout = self.mainCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let cellWidth = layout.itemSize.width + layout.minimumLineSpacing
        
        // 총 셀 개수 구하기
        let totalItems = mainCollectionView.numberOfItems(inSection: 0)
        
        // 마지막 셀의 인덱스
        currentIdx = CGFloat(totalItems - 1)
        
        // 마지막 셀로 이동하기 위한 offset 설정
        let offset = CGPoint(x: currentIdx * cellWidth - mainCollectionView.contentInset.left, y: 0)
        
        // 스크롤 애니메이션
        mainCollectionView.setContentOffset(offset, animated: true)
        
        // 검색해서 선택한 장소의 위치 마커 지우기
        self.searchMarker.mapView = nil
        
        // 이전 장소 위치 마커 지우기
        self.locationMarker.mapView = nil
        
        setLocationMarker(Int(currentIdx))
    }
    
    func setLocationMarker(_ index: Int) {
        let currentData = realmData[Int(index)]
        locationMarker.position = NMGLatLng(lat: Double(currentData.lat)!, lng: Double(currentData.lng)!)
        locationMarker.mapView = self.mainMapView
        locationMarker.iconImage = NMFOverlayImage(name: AppStyles.ColorCircle.backgroundCircle[currentData.colorIndex])
        locationMarker.captionAligns = [NMFAlignType.center]
        
        let infoWindow = NMFInfoWindow()
        let dataSource = CustomInfoWindowDataSource(currentData.scheduleTitle, currentData.startDate, currentData.endDate, currentData.colorIndex)
        infoWindow.dataSource = dataSource
        infoWindow.open(with: locationMarker, alignType: .center)
        infoWindow.offsetY = 6
        
        moveMapViewCamera(Double(currentData.lat)!, Double(currentData.lng)!)
    }
}

class SearchFloatingPanelLayout: FloatingPanelLayout {
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

