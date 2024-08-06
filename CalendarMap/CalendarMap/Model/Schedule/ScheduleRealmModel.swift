//
//  ScheduleRealmModel.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/04/25.
//

import Foundation
import RealmSwift

class ScheduleDetailInfo: Object {
    @Persisted(primaryKey: true) var objectID: ObjectId
    @Persisted var colorIndex: Int = 0
    @Persisted var color: String = ""
    @Persisted var scheduleTitle: String = ""
    @Persisted var locationName: String = ""
    @Persisted var locationId: String = ""
    @Persisted var address: String = ""
    @Persisted var roadAddress: String = ""
    @Persisted var lat: String = ""
    @Persisted var lng: String = ""
    @Persisted var isAllDay: Bool = false
    @Persisted var startDate: String = ""
    @Persisted var endDate: String = ""
    @Persisted var memo: String = ""
    
    convenience init(colorIndex: Int, color: String, scheduleTitle: String, locationName: String, locationId: String, address: String, roadAddress: String, lat: String, lng: String, isAllday: Bool, startDate: String, endDate: String, memo: String) {
        self.init()
        
        self.colorIndex = colorIndex
        self.color = color
        self.scheduleTitle = scheduleTitle
        self.locationName = locationName
        self.locationId = locationId
        self.address = address
        self.roadAddress = roadAddress
        self.lat = lat
        self.lng = lng
        self.isAllDay = isAllDay
        self.startDate = startDate
        self.endDate = endDate
        self.memo = memo
    }
}
