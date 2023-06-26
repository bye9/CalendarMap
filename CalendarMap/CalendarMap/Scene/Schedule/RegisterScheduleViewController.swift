//
//  RegisterScheduleViewController.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/03/29.
//

import UIKit
import RealmSwift

class RegisterScheduleViewController: UIViewController {

    let realm = try! Realm()
    
    
    @IBOutlet var lblTest: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
        
        let test = self.registerScheduleDetailInfo("blue", "동아리 모임", "서울 마포구 상암동 1657", "서울 마포구 상암산로1길 26", "37.5790897397893", "126.888144865456", true, "2023-05-16", "2023-05-17", "테스트 메모")
        
        try! realm.write {
            realm.add(test)
        }
        
        getScheduleDetailInfo()
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
        self.lblTest.text = String(scheduleDetailInfo[0].title)
        
        print(Realm.Configuration.defaultConfiguration.fileURL)
    }
    
}

