//
//  ScheduleViewModel.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 7/9/24.
//

import Foundation

class ScheduleViewModel: NSObject {
    var schedule: ScheduleInfo?
    
    var titleString: String? {
        return schedule?.title
    }
    
    var startDateString: String? {
        return schedule?.startDate
    }
    
    var endDateString: String? {
        return schedule?.endDate
    }
    
    var locationString: String? {
        return schedule?.location
    }
    
    func scheduleSelected(_ title: String, _ startDate: String, _ endDate: String, _ location: String) {
         self.schedule = .init(title: title, startDate: startDate, endDate: endDate, location: location)
    }
    
}
