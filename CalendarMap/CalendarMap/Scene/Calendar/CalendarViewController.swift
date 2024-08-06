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
    var realmData: Results<ScheduleDetailInfo>!
    let selectDateFormatter = DateFormatter()
    let headerDateFormatter = DateFormatter()
    var events = [Date]()
    var scheduleViewModel = ScheduleViewModel()
    
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
        setEvents()
    }
    
    func setupViews() {
        self.calendarView.delegate = self
        self.calendarView.dataSource = self
        self.calendarView.headerHeight = 0
        self.calendarView.scope = .month
        self.calendarView.locale = Locale(identifier: "ko_KR")
        self.calendarView.appearance.caseOptions = FSCalendarCaseOptions.weekdayUsesSingleUpperCase
        
        headerDateFormatter.dateFormat = "YYYY년 MM월"
        self.headerLabel.text = headerDateFormatter.string(from: self.today)
        
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
    
    func setEvents() {
        selectDateFormatter.locale = Locale(identifier: "ko_KR")
        selectDateFormatter.dateFormat = "yyyy.M.d"
        
        let scheduleDetailInfo = realm.objects(ScheduleDetailInfo.self)
        
        for i in 0..<scheduleDetailInfo.count {
            let yearMonthDay = scheduleDetailInfo[i].startDate.components(separatedBy: " ")[0].components(separatedBy: ".")

            guard let event = selectDateFormatter.date(from: yearMonthDay[0]+"."+yearMonthDay[1]+"."+yearMonthDay[2]) else { return }
            events.append(event)
        }
    }
    
    func getRealmDataFrom(_ date: Date) {
        let data = realm.objects(ScheduleDetailInfo.self)
        if data.count > 0 {
            let sortedData = data.sorted(byKeyPath: "startDate", ascending: true)
            let newString = selectDateFormatter.string(from: date)
            realmData = sortedData.filter("startDate CONTAINS '\(newString)'")
            print(realmData!)
        } else {
            realmData = data
        }
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
    }
    
    // 날짜를 선택했을 때
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        getRealmDataFrom(date)
        
        mainCollectionView.reloadData()
    }
    
    // 날짜 밑에 이벤트 dot 개수
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let newString = selectDateFormatter.string(from: date)
        guard let newDate = selectDateFormatter.date(from: newString) else { return 0
        }
        
        if self.events.contains(newDate) {
            return 1
        }
        
        return 0
    }
    
    // 이벤트 dot 기본색상
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        let newString = selectDateFormatter.string(from: date)
        guard let newDate = selectDateFormatter.date(from: newString) else { return nil }
        
        if self.events.contains(newDate) {
            return [UIColor.green]
        }
        
        return nil
    }
    
    // Selected Event Dot 색상 분기처리 - FSCalendarDelegateAppearance
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        let newString = selectDateFormatter.string(from: date)
        guard let newDate = selectDateFormatter.date(from: newString) else { return nil }
        
        if self.events.contains(newDate) {
            return [UIColor.green]
        }
        
        return nil
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
        if realmData != nil {
            noScheduleView.isHidden = true
            mainCollectionView.isHidden = false
            return realmData.count
        } else {
            noScheduleView.isHidden = false
            mainCollectionView.isHidden = true
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let scheduleDetailViewController = UIStoryboard(name: "Schedule", bundle: .main).instantiateViewController(withIdentifier: "ScheduleDetailViewController") as? ScheduleDetailViewController else { return }
        
        let data = realmData[indexPath.row]
        // 일정 상세보기 데이터 세팅
        scheduleViewModel.scheduleSelected(data.scheduleTitle, data.startDate, data.endDate, data.locationName)
        
        scheduleDetailViewController.viewModel = scheduleViewModel
        self.present(scheduleDetailViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCollectionViewCell", for: indexPath) as? CalendarCollectionViewCell else { return UICollectionViewCell() }
    
        let data = realmData[indexPath.row]
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
