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
    let selectDateFormatter = DateFormatter()
    let headerDateFormatter = DateFormatter()
    var events = [Date]()
    
    private var page: Date?
    private lazy var today: Date = {
        return Date()
    }()
    
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var headerLabel: UILabel!
    
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
//        self.calendarView.appearance.headerDateFormat = "YYYY년 MM월"
//        self.calendarView.appearance.headerTitleFont = AppStyles.Fonts.Heading1
//        self.calendarView.appearance.headerTitleColor = AppStyles.Color.Black
        self.headerLabel.text = headerDateFormatter.string(from: self.today)
        
        self.calendarView.appearance.weekdayFont = AppStyles.Fonts.Body1
        self.calendarView.appearance.weekdayTextColor = AppStyles.Color.Gray5
        self.calendarView.appearance.titleFont = AppStyles.Fonts.Heading2
        self.calendarView.appearance.titleDefaultColor = AppStyles.Color.Black
        // 이전 달 & 다음 달 글씨 투명도
        self.calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        self.calendarView.appearance.todayColor = UIColor.gray
        self.calendarView.appearance.selectionColor = AppStyles.Color.Blue
        
    }
    
    func setEvents() {
        selectDateFormatter.locale = Locale(identifier: "ko_KR")
        selectDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        selectDateFormatter.dateFormat = "yyyy.M.d"
        
        let scheduleDetailInfo = realm.objects(ScheduleDetailInfo.self)
        
        for i in 0..<scheduleDetailInfo.count {
            let yearMonthDay = scheduleDetailInfo[i].startDate.components(separatedBy: " ")[0].components(separatedBy: ".")

            guard let event = selectDateFormatter.date(from: yearMonthDay[0]+"."+yearMonthDay[1]+"."+yearMonthDay[2]) else { return }
            events.append(event)
        }
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
    
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    // 현재 페이지가 변경되었을 때
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.headerLabel.text = headerDateFormatter.string(from: calendar.currentPage)
    }
    
    // 날짜를 선택했을 때
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {

    }
    
    // 날짜 밑에 이벤트 dot 개수
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let newString = selectDateFormatter.string(from: date)
        guard let newDate = selectDateFormatter.date(from: newString) else { return 0 }
        
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
