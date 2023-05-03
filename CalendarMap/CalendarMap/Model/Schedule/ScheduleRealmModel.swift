//
//  ScheduleRealmModel.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/04/25.
//

import Foundation
import RealmSwift

class ScheduleDetailInfo: Object {
    @objc dynamic var color = ""
    @objc dynamic var title = ""
    @objc dynamic var address = ""
    @objc dynamic var roadAddress = ""
    @objc dynamic var isAllDay = false
    @objc dynamic var startDate = ""
    @objc dynamic var endDate = ""
    @objc dynamic var memo = ""
}
