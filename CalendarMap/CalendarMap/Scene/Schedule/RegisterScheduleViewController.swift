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
    var scheduleTitle: String?
    var locationName: String?
    var locationId: String?
    var address: String?
    var roadAddress: String?
    var lat: String?
    var lng: String?
    var startDate: String?
    var endDate: String?
    var completionHandler: ((String, String) -> ())?
    var color: String?
    var index: Int = 0
    let dateformatter = DateFormatter()
    
    @IBOutlet weak var colorCircleButton: UIButton!
    @IBOutlet weak var scheduleTitleTextField: UITextField!
    @IBOutlet weak var locationNameButton: UIButton!
    @IBOutlet weak var deleteLocationNameButton: UIButton!
    @IBOutlet weak var allDaySwitch: UISwitch!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var memoTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        initFloatingPanel()
    }
    
    func setupViews() {
        hideKeyboardWhenTappedAround()
        scheduleTitleTextField.attributedPlaceholder = NSAttributedString(string: "일정 제목 입력", attributes: [NSAttributedString.Key.foregroundColor: AppStyles.Color.Gray6])

        locationNameButton.setTitle(locationName, for: .normal)
        locationNameButton.setTitleColor(UIColor.black, for: .normal)
        locationNameButton.contentHorizontalAlignment = .left
        
        dateformatter.dateFormat = "yyyy.M.d.E a hh:mm"
        dateformatter.locale = Locale(identifier: "ko_KR")
        
        startDatePickerChanged()
        endDatePickerChanged()
        
        startDatePicker.addTarget(self, action: #selector(startDatePickerChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(endDatePickerChanged), for: .valueChanged)
        startDatePicker.minimumDate = Date()
        
        memoTextView.delegate = self
        memoTextView.text = "메모를 입력해주세요."
        memoTextView.textColor = UIColor.lightGray
        memoTextView.font = AppStyles.Fonts.Body1
        memoTextView.textContainer.lineFragmentPadding = 0
        memoTextView.textContainerInset = .zero
        
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        self.scheduleTitle = scheduleTitleTextField.text
        
        let test = self.registerScheduleDetailInfo(index, color ?? "color_blue", scheduleTitle!, locationName!, locationId! ,address!, roadAddress!, lat!, lng!, allDaySwitch.isOn, startDate!, endDate!, memoTextView.text)
        do {
            try realm.write {
                realm.add(test)
            }
        } catch {
            print(error)
        }
        
        getScheduleDetailInfo()
        completionHandler?(lat ?? "0", lng ?? "0")
    
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func colorCircleButtonTapped(_ sender: UIButton) {
        reloadFloatingPanel()
    }
    
    func registerScheduleDetailInfo(_ colorIndex: Int, _ color: String, _ scheduleTitle: String, _ locationName: String, _ locationId: String, _ address: String, _ roadAddress: String, _ lat: String, _ lng: String, _ isAllDay: Bool, _ startDate: String, _ endDate: String, _ memo: String) -> ScheduleDetailInfo {
        let scheduleDetailInfo = ScheduleDetailInfo(colorIndex: colorIndex, color: color, scheduleTitle: scheduleTitle, locationName: locationName, locationId: locationId, address: address, roadAddress: roadAddress, lat: lat, lng: lng,
                                                    isAllday: isAllDay, startDate: startDate, endDate: endDate, memo: memo)
        return scheduleDetailInfo
    }
    
    @objc func startDatePickerChanged() {
        startDate = dateformatter.string(from: startDatePicker.date)
        endDatePicker.minimumDate = startDatePicker.date
        print(startDate)
    }
    
    @objc func endDatePickerChanged() {
        endDate = dateformatter.string(from: endDatePicker.date)
        print(endDate)
    }
    
    func getScheduleDetailInfo() {
        let scheduleDetailInfo = realm.objects(ScheduleDetailInfo.self)
        print(scheduleDetailInfo)
//        self.testLabel.text = String(scheduleDetailInfo[0].locationName)
        
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
            vc.colorIndex = self.index
            vc.colorSelectCollectionView.backgroundColor = .white
            self.floatingPanel.track(scrollView: vc.colorSelectCollectionView)
            self.floatingPanel.addPanel(toParent: self, animated: true)
            self.floatingPanel.backdropView.dismissalTapGestureRecognizer.isEnabled = true
            
            vc.completionHandler = { colorIndex in
                print(colorIndex)
                self.index = colorIndex
                self.colorCircleButton.setImage(UIImage(named: AppStyles.ColorCircle.colorImages[colorIndex]), for: .normal)
                self.color = AppStyles.ColorCircle.colorImages[colorIndex]
                self.floatingPanel.removePanelFromParent(animated: true)
            }
             
        }
    }
    
}

extension RegisterScheduleViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if memoTextView.text.isEmpty {
            memoTextView.text = "메모를 입력해주세요."
            memoTextView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if memoTextView.textColor == UIColor.lightGray {
            memoTextView.text = nil
            memoTextView.textColor = UIColor.black
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.memoTextView.resignFirstResponder()
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

