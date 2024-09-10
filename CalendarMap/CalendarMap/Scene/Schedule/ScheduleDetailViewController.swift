//
//  ScheduleDetailViewController.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 7/8/24.
//

import UIKit
import RealmSwift
import NMapsMap
import CoreLocation

class ScheduleDetailViewController: UIViewController {
    let realm = try! Realm()
    let locationManager = CLLocationManager()
    let locationMarker = NMFMarker()
    var viewModel: ScheduleViewModel!
    var locationId: String?
    var locationName: String?
    var locationLat: String?
    var locationLng: String?

    @IBOutlet weak var colorCircleButton: UIButton!
    @IBOutlet weak var scheduleTitleLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var mapView: NMFMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    func setupViews() {
        // 기본키: scheduleTitle, locationName, startDate
        let scheduleDetailInfo = realm.objects(ScheduleDetailInfo.self)
            .filter("scheduleTitle == '\(viewModel.schedule!.title)' AND locationName == '\(viewModel.schedule!.location)' AND startDate == '\(viewModel.schedule!.startDate)'")
        guard let scheduleInfo = scheduleDetailInfo.first else { return }
        
        locationId = scheduleInfo.locationId
        locationName = scheduleInfo.locationName
        locationLat = scheduleInfo.lat
        locationLng = scheduleInfo.lng
        
        let color = AppStyles.ColorCircle.colorImages[scheduleInfo.colorIndex]
        self.colorCircleButton.setImage(UIImage(named: color), for: .normal)
        self.scheduleTitleLabel.text = scheduleInfo.scheduleTitle
        
        let isAllDay = scheduleInfo.isAllDay
        self.startDateLabel.text = isAllDay ? "하루종일" : scheduleInfo.startDate
        self.endDateLabel.text = isAllDay ? "하루종일" : scheduleInfo.endDate
        
        self.locationNameLabel.text = locationName
        self.addressLabel.text = scheduleInfo.address
        self.memoLabel.text = scheduleInfo.memo
        
        self.mapView.touchDelegate = self
        
        locationMarker.position = NMGLatLng(lat: Double(scheduleInfo.lat)!, lng: Double(scheduleInfo.lng)!)
        locationMarker.mapView = self.mapView
        locationMarker.iconImage = NMFOverlayImage(name: AppStyles.ColorCircle.backgroundCircle[scheduleInfo.colorIndex])
        locationMarker.captionAligns = [NMFAlignType.center]
        
        let infoWindow = NMFInfoWindow()
        let dataSource = CustomInfoWindowDataSource(scheduleInfo.scheduleTitle, scheduleInfo.startDate, scheduleInfo.endDate, scheduleInfo.colorIndex)
        infoWindow.dataSource = dataSource
        infoWindow.open(with: locationMarker, alignType: .center)
        infoWindow.offsetY = 6
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: Double(scheduleInfo.lat)!, lng: Double(scheduleInfo.lng)!))
        cameraUpdate.animation = .easeIn
        DispatchQueue.main.async {
            self.mapView.moveCamera(cameraUpdate) { (isCancelled) in
                if isCancelled {
                    print("카메라 이동 취소")
                } else {
                    print("카메라 이동 완료")
                }
            }
        }
    }
}

extension ScheduleDetailViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        // MARK: 다른 지도 맵 열기
        guard let locationId = locationId, let locationName = locationName, let locationLat = locationLat, let locationLng = locationLng else { return }
        self.showActionSheet(controller: self, id: locationId, locationName: locationName, lat: locationLat, lng: locationLng)
    }
    
    func showActionSheet(controller: UIViewController, id: String, locationName: String, lat: String, lng: String) {
        let alert = UIAlertController(title: "", message: "지도", preferredStyle: .actionSheet)
          alert.addAction(UIAlertAction(title: "카카오맵에서 열기", style: .default, handler: { (_) in
              let url = URL(string: "kakaomap://place?id=\(id)")!
              let appStoreURL = URL(string: "https://apps.apple.com/us/app/kakaomap-korea-no-1-map/id304608425")!
              
              if UIApplication.shared.canOpenURL(url) {
                  UIApplication.shared.open(url)
              } else {
                  UIApplication.shared.open(appStoreURL)
              }
          }))

          alert.addAction(UIAlertAction(title: "네이버맵에서 열기", style: .default, handler: { (_) in
              guard let name = locationName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
              
              let url = URL(string: "nmap://place?lat=\(lat)&lng=\(lng)&name=\(name)&appname=com.bye9.CalendarMap")!
              let appStoreURL = URL(string: "https://apps.apple.com/us/app/naver-map-navigation/id311867728")!
              
              if UIApplication.shared.canOpenURL(url) {
                  UIApplication.shared.open(url)
              } else {
                  UIApplication.shared.open(appStoreURL)
              }
          }))

          alert.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: { (_) in
              
          }))

          controller.present(alert, animated: true, completion: {
              
          })
    }
}
