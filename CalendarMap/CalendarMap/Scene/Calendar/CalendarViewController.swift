//
//  CalendarViewController.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 11/27/23.
//

import UIKit
import RealmSwift
import FSCalendar

class CalendarViewController: UIViewController {
    let realm = try! Realm()
    var selectDayData = [ScheduleDetailInfo]()
    let dateFormatter = DateFormatter()
    let headerDateFormatter = DateFormatter()
    var events = [Date]()
    var scheduleViewModel = ScheduleViewModel()
    var monthData: Results<ScheduleDetailInfo>?
    
    private var page: Date?
    private lazy var today: Date = {
        return Date()
    }()
    
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var noScheduleView: UIView!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setMonthEvents(self.today)
        selectDayData = eventsForDate(today)
    }
    
    func setupViews() {
        self.calendarView.delegate = self
        self.calendarView.dataSource = self
        self.calendarView.placeholderType = .none
        self.calendarView.headerHeight = 0
        self.calendarView.scope = .month
        self.calendarView.locale = Locale(identifier: "ko_KR")
        self.calendarView.appearance.caseOptions = FSCalendarCaseOptions.weekdayUsesSingleUpperCase
        
        headerDateFormatter.dateFormat = "YYYY년 MM월"
        self.headerLabel.text = headerDateFormatter.string(from: self.today)
        
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.M.d"
        
        self.calendarView.appearance.weekdayFont = AppStyles.Fonts.Body1
        self.calendarView.appearance.weekdayTextColor = AppStyles.Color.Gray5
        self.calendarView.appearance.titleFont = AppStyles.Fonts.Heading2
        self.calendarView.appearance.titleDefaultColor = AppStyles.Color.Black
        // 이전 달 & 다음 달 글씨 투명도
        self.calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        self.calendarView.appearance.todayColor = UIColor.gray
        self.calendarView.appearance.selectionColor = AppStyles.Color.Blue
        
        mainCollectionView.backgroundColor = .clear
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.decelerationRate = .fast
        mainCollectionView.register(UINib(nibName: "CalendarCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CalendarCollectionViewCell")
    }
    
    func setMonthEvents(_ date: Date) {
        let monthDateFormatter = DateFormatter()
        monthDateFormatter.locale = Locale(identifier: "ko_KR")
        monthDateFormatter.dateFormat = "M"
        let monthString = monthDateFormatter.string(from: date)
        monthData = realm.objects(ScheduleDetailInfo.self).filter("startDate CONTAINS '.\(monthString).'")
    }
    
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    

    @IBAction func moveToPrev(_ sender: UIButton) {
        self.moveCurrentPage(moveUp: false)
    }
    
    @IBAction func moveToNext(_ sender: UIButton) {
        self.moveCurrentPage(moveUp: true)
    }
    
    private func moveCurrentPage(moveUp: Bool) {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = moveUp ? 1 : -1
        
        self.page = calendar.date(byAdding: dateComponents, to: self.page ?? self.today)
        self.calendarView.setCurrentPage(self.page!, animated: false)
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

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    // 현재 페이지가 변경되었을 때
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.headerLabel.text = headerDateFormatter.string(from: calendar.currentPage)
        
        setMonthEvents(calendar.currentPage)
        calendarView.reloadData()
        mainCollectionView.reloadData()
    }
    
    // 날짜를 선택했을 때
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectDayData = eventsForDate(date)
        mainCollectionView.reloadData()
    }
    
    // 특정 날짜에 해당하는 이벤트 개수를 반환하는 메서드
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return eventsForDate(date).count
    }
    
    // 특정 날짜에 해당하는 이벤트 색상을 반환하는 메서드
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        let events = eventsForDate(date)
        
        return events.map { event in
            return colorForEvent(event)
        }
    }
    
    /// 특정 날짜에 해당하는 일정을 반환하는 함수
    func eventsForDate(_ date: Date) -> [ScheduleDetailInfo] {
        guard let monthData = monthData else { return [] }
        let dateString = dateFormatter.string(from: date) + "."
        let filteredSchedules = monthData.filter("startDate BEGINSWITH '\(dateString)'")
        
        return filteredSchedules.map { $0 }
    }
    
    /// 특정 일정에 해당하는 색상을 반환하는 함수
    func colorForEvent(_ event: ScheduleDetailInfo) -> UIColor {
        switch event.colorIndex {
        case 0:
            return AppStyles.Color.Blue
        case 1:
            return AppStyles.Color.Purple
        case 2:
            return AppStyles.Color.Pink
        case 3:
            return AppStyles.Color.Red
        case 4:
            return AppStyles.Color.Orange
        case 5:
            return AppStyles.Color.Yellow
        case 6:
            return AppStyles.Color.Green
        case 7:
            return AppStyles.Color.LightGreen
        case 8:
            return AppStyles.Color.Gray7
        case 9:
            return AppStyles.Color.Gray3
        default:
            return .gray
        }
    }
    
    // 선택한 이벤트 색상
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        let events = eventsForDate(date)
        
        return events.map { event in
            return colorForEvent(event)
        }
    }
    
    // 특정 날짜의 텍스트 색상을 변경하는 메서드
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let calendar = Calendar.current
        let components = calendar.component(.weekday, from: date)
        
        if components == 7 { // 토요일
            return  UIColor.blue
        } else if components == 1 { // 일요일
            return UIColor.red
        }
        
        return nil // 기본 색상
    }
    
    // 이벤트 dot 사이즈 조정
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        let eventScaleFactor: CGFloat = 1.5
        cell.eventIndicator.transform = CGAffineTransform(scaleX: eventScaleFactor, y: eventScaleFactor)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventOffsetFor date: Date) -> CGPoint {
        return CGPoint(x: 0, y: 3)
    }
    
}

extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectDayData.count != 0 {
            noScheduleView.isHidden = true
            mainCollectionView.isHidden = false
            return selectDayData.count
        } else {
            noScheduleView.isHidden = false
            mainCollectionView.isHidden = true
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let scheduleDetailViewController = UIStoryboard(name: "Schedule", bundle: .main).instantiateViewController(withIdentifier: "ScheduleDetailViewController") as? ScheduleDetailViewController else { return }
        
        let data = selectDayData[indexPath.row]
        // 일정 상세보기 데이터 세팅
        scheduleViewModel.scheduleSelected(data.scheduleTitle, data.startDate, data.endDate, data.locationName)
        
        scheduleDetailViewController.viewModel = scheduleViewModel
        self.present(scheduleDetailViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCollectionViewCell", for: indexPath) as? CalendarCollectionViewCell else { return UICollectionViewCell() }
    
        let data = selectDayData[indexPath.row]
        cell.colorCircle.image = UIImage(named: data.color)
        cell.scheduleName.text = data.scheduleTitle
        
        let startArray = data.startDate.components(separatedBy: " ")
        let startTime = "\(startArray[1]) \(startArray[2])"
        
        let endArray = data.endDate.components(separatedBy: " ")
        let endTime = "\(endArray[1]) \(endArray[2])"
        
        // 2023.7.26.수요일 오후 11:55
        cell.scheduleTime.text = "\(startTime) - \(endTime)"
        cell.schedulePlace.text = data.locationName
        cell.id = data.locationId
        cell.locationLat = data.lat
        cell.locationLng = data.lng
        
        cell.delegate = self
    
        return cell
    }
}

extension CalendarViewController: CalendarButtonTappedDelegate {
    func openMapButtonTapped(cell: CalendarCollectionViewCell, id: String, locationName: String, lat: String, lng: String) {
        self.showActionSheet(controller: self, id: id, locationName: locationName, lat: lat, lng: lng)
    }
}
