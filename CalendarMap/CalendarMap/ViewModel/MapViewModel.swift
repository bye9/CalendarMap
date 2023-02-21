//
//  MapViewModel.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/02/21.
//

import Foundation

class MapViewModel: NSObject {
    var apiService = APIService()

    func fetchCoords(coords: String, completion: @escaping([Map]?) -> Void) {
        apiService.fetchCoords(coords: coords) { data in
            completion(data)
        }
    }
    
}
