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
    
    
    /// 검색된 장소 테이블 뷰 셀 클릭 시, 지도 카메라 이동하기 위해 카카오 주소로 네이버 지도의 좌표 구하기
    /// - Parameters:
    ///   - searchAddress: 카카오맵 주소
    ///   - completion: 네이버 지도 좌표
    func fetchCoordinate(searchAddress: String, completion: @escaping (SearchCoordinate?) -> Void) {
        apiService.fetchCoordinate(searchAddress: searchAddress) { data in
            completion(data)
        }
    }
    
    /// 장소 검색 시, 현재 위치의 좌표와 함께 카카오 장소 검색하기 API
    /// - Parameters:
    ///   - searchWord: 장소 검색어
    ///   - lng: 경도(ex: 126.7474436759949)
    ///   - lat: 위도(ex: 37.67615277418487)
    ///   - completion: 카카오 장소
    func fetchKakaoSearchLocation(searchWord: String, lng: String, lat: String, completion: @escaping (KakaoSearchLocation?) -> Void) {
        apiService.fetchKakaoSearchLocation(searchWord: searchWord, longitude: lng, latitude: lat) { data in
            completion(data)
        }
    }
}
