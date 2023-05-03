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
        let test = self.registerScheduleDetailInfo("1", "2", "3", "4", true, "5", "6", "7")
        
        try! realm.write {
            realm.add(test)
        }
        
        getScheduleDetailInfo()
    }
    
    func registerScheduleDetailInfo(_ color: String, _ title: String, _ address: String, _ roadAddress: String,
                                    _ isAllDay: Bool, _ startDate: String, _ endDate: String, _ memo: String) -> ScheduleDetailInfo {
        let scheduleDetailInfo = ScheduleDetailInfo()
        scheduleDetailInfo.color = color
        scheduleDetailInfo.title = title
        scheduleDetailInfo.address = address
        scheduleDetailInfo.roadAddress = roadAddress
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

