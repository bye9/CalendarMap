//
//  ScheduleModel.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/02/21.
//

import Foundation

struct ScheduleInfo {
    let title: String
    let time: String
    let location: String
    
    init(title: String, time: String, location: String) {
        self.title = title
        self.time = time
        self.location = location
    }
}
