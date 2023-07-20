//
//  RegisterScheduleViewController.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/03/29.
//

import UIKit
import RealmSwift
import FloatingPanel

class RegisterScheduleViewController: UIViewController {
    let realm = try! Realm()
    var floatingPanel: FloatingPanelController!
    var name: String?
    var lat: String?
    var lng: String?
    var completionHandler: ((String, String) -> ())?
    var color: String?
    var index: Int = 0
    
    @IBOutlet weak var colorCircleButton: UIButton!
    @IBOutlet weak var scheduleTitleTextField: UITextField!
    @IBOutlet weak var locationNameButton: UIButton!
    @IBOutlet weak var deleteLocationNameButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        initFloatingPanel()
    }
    
    func setupViews() {
        scheduleTitleTextField.attributedPlaceholder = NSAttributedString(string: "일정 제목 입력", attributes: [NSAttributedString.Key.foregroundColor: AppStyles.Color.Gray6])

        locationNameButton.setTitle(name, for: .normal)
        locationNameButton.setTitleColor(UIColor.black, for: .normal)
        locationNameButton.contentHorizontalAlignment = .left
        
        colorCircleButton.layer.cornerRadius = colorCircleButton.frame.width / 2
        colorCircleButton.layer.masksToBounds = true
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        completionHandler?(lat ?? "0", lng ?? "0")
    
        self.navigationController?.popViewController(animated: true)
        
        
        
//        let test = self.registerScheduleDetailInfo("blue", "동아리 모임", "서울 마포구 상암동 1657", "서울 마포구 상암산로1길 26", "37.5790897397893", "126.888144865456", true, "2023-05-16", "2023-05-17", "테스트 메모")
//
//        try! realm.write {
//            realm.add(test)
//        }
//
//        getScheduleDetailInfo()
    }
    
    @IBAction func colorCircleButtonTapped(_ sender: UIButton) {
        reloadFloatingPanel()
    }
    
    func registerScheduleDetailInfo(_ color: String, _ title: String, _ address: String, _ roadAddress: String, _ lat: String, _ lng: String,
                                    _ isAllDay: Bool, _ startDate: String, _ endDate: String, _ memo: String) -> ScheduleDetailInfo {
        let scheduleDetailInfo = ScheduleDetailInfo()
        scheduleDetailInfo.color = color
        scheduleDetailInfo.title = title
        scheduleDetailInfo.address = address
        scheduleDetailInfo.roadAddress = roadAddress
        scheduleDetailInfo.lat = lat
        scheduleDetailInfo.lng = lng
        scheduleDetailInfo.isAllDay = isAllDay
        scheduleDetailInfo.startDate = startDate
        scheduleDetailInfo.endDate = endDate
        scheduleDetailInfo.memo = memo
        
        return scheduleDetailInfo
    }
    
    func getScheduleDetailInfo() {
        let scheduleDetailInfo = realm.objects(ScheduleDetailInfo.self)
//        self.testLabel.text = String(scheduleDetailInfo[0].title)
        
        print(Realm.Configuration.defaultConfiguration.fileURL)
    }
    
    /// FloatingPanelController(bottom sheet) 화면 설정
    func initFloatingPanel() {
        floatingPanel = FloatingPanelController()
        floatingPanel.changePanelStyle()
        floatingPanel.delegate = self
        floatingPanel.isRemovalInteractionEnabled = true
        floatingPanel.layout = ColorFloatingPanelLayout()
    }
    
    /// 색상 선택 시, 올라오는 하단 Carousel view에 색상 목록 컬렉션 뷰 표시
    func reloadFloatingPanel() {
        DispatchQueue.main.async {
            let contentVC = UIStoryboard(name: "Schedule", bundle: nil).instantiateViewController(withIdentifier: "ColorCircleCollectionViewController")
            self.floatingPanel.set(contentViewController: contentVC)
            let vc = contentVC as! ColorCircleCollectionViewController
//            vc.locations = items
            vc.colorIndex = self.index
            vc.colorSelectCollectionView.backgroundColor = .white
            self.floatingPanel.track(scrollView: vc.colorSelectCollectionView)
            self.floatingPanel.addPanel(toParent: self, animated: true)
            self.floatingPanel.backdropView.dismissalTapGestureRecognizer.isEnabled = true
            
            vc.completionHandler = { colorIndex in
                print(colorIndex)
                self.index = colorIndex
                self.colorCircleButton.backgroundColor = vc.colorBackground[colorIndex]
                self.floatingPanel.removePanelFromParent(animated: true)
            }
            
        }
    }
    
}

extension RegisterScheduleViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidMove(_ fpc: FloatingPanelController) {
        if floatingPanel.isAttracting == false {
            let loc = floatingPanel.surfaceLocation
            let minY = floatingPanel.surfaceLocation(for: .half).y
            let maxY = floatingPanel.surfaceLocation(for: .half).y
            floatingPanel.surfaceLocation = CGPoint(x: loc.x, y: min(max(loc.y, minY), maxY))
        }
    }
}


class ColorFloatingPanelLayout: FloatingPanelLayout {
    var position: FloatingPanelPosition {
        return .bottom
    }

    var initialState: FloatingPanelState {
        return .half
    }

    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .half: FloatingPanelLayoutAnchor(absoluteInset: 228, edge: .bottom, referenceGuide: .superview),
        ]
    }
    
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        switch state {
        case .half: return 0.4
        default: return 0.0
        }
    }
}

