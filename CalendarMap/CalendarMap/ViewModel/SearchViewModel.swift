//
//  SearchViewModel.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/03/06.
//

import Foundation

class SaerchViewModel: NSObject {
    var apiService = APIService()
    
    func fetchSearchLocal(searchWord: String, completion: @escaping ([SearchLocal]?) -> Void) {
        apiService.fetchSearchLocal(searchWord: searchWord) { data in
            completion(data)
        }
    }
}
