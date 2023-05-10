//
//  SearchViewModel.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/03/06.
//

import Foundation

class SearchViewModel: NSObject {
    var apiService = APIService()
    
    func fetchSearchLocal(searchWord: String, completion: @escaping (SearchLocation?) -> Void) {
        apiService.fetchSearchLocal(searchWord: searchWord) { data in
            completion(data)
        }
    }
    
    func fetchCoordinate(searchAddress: String, completion: @escaping (SearchCoordinate?) -> Void) {
        apiService.fetchCoordinate(searchAddress: searchAddress) { data in
            completion(data)
        }
    }
    
    func fetchKakaoSearchLocation(searchWord: String, lon: String, lat: String, completion: @escaping (KakaoSearchLocation?) -> Void) {
        apiService.fetchKakaoSearchLocation(searchWord: searchWord, longitude: lon, latitude: lat) { data in
            completion(data)
        }
    }
}
