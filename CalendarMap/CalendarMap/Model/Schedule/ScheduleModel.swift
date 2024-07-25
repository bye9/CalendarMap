//
//  ScheduleModel.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/02/21.
//

import Foundation

struct ScheduleInfo {
    let title: String
    let startDate: String
    let endDate: String
    let location: String
    
    init(title: String, startDate: String, endDate: String, location: String) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
    }
}
