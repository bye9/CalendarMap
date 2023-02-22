//
//  MapViewModel.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/02/21.
//

import Foundation

class MapViewModel: NSObject {
    var apiService = APIService()

    func fetchAddress(coords: String, completion: @escaping([Map]?) -> Void) {
        apiService.fetchAddress(coords: coords) { data in
            completion(data)
        }
    }
    
}
