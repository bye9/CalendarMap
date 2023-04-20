//
//  APIService.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/02/21.
//

import Foundation

class APIService: NSObject {

    // TODO: 삭제예정
    // 좌표 -> 주소
    func fetchAddress(coords: String, completion: @escaping ([Map]?) -> Void) {
        let reverseGeocodingURL = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc"
        let urlString = URL(string: "\(reverseGeocodingURL)?coords=\(coords)&output=json&orders=legalcode,admcode,addr,roadaddr")!
    
        let clientId = Bundle.main.object(forInfoDictionaryKey: "NMFClientId") as! String
        let clientSecret = Bundle.main.object(forInfoDictionaryKey: "NMFClientSecret") as! String
        
        var request = URLRequest(url: urlString)
        request.httpMethod = "GET"
        request.setValue(clientId, forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.setValue(clientSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Error: error calling GET")
                print(error!)
                completion(nil)
                return
            }
            // 옵셔널 바인딩
            guard let safeData = data else {
                print("Error: Did not receive data")
                completion(nil)
                return
            }
            // HTTP 200번대 정상코드인 경우만 다음 코드로 넘어감
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed")
                completion(nil)
                return
            }
                
            if let data = data {
                let jsonDecoder = JSONDecoder()
                    
                let maps = try! jsonDecoder.decode(Map.self, from: data)
                completion([maps])
            }
        }.resume()
    }
    
    /// 검색 API를 사용해 네이버 지역 서비스에 등록된 업체 및 기관을 검색한 결과를 XML 형식 또는 JSON 형식으로 반환합니다.
    /// - Parameters:
    ///   - searchWord: 검색어
    ///   - completion: escaping 클로저 () -> Void
    func fetchSearchLocal(searchWord: String, completion: @escaping (SearchLocation?) -> Void) {
        let url = "https://openapi.naver.com/v1/search/local.json"
        let word = searchWord.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = URL(string: "\(url)?query=\(word)&display=5&start=1&sort=random")!

        let clientId = Bundle.main.object(forInfoDictionaryKey: "X-Naver-Client-Id") as! String
        let clientSecret = Bundle.main.object(forInfoDictionaryKey: "X-Naver-Client-Secret") as! String

        var request = URLRequest(url: urlString)
        request.httpMethod = "GET"
        request.setValue(clientId, forHTTPHeaderField: "X-Naver-Client-Id")
        request.setValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Error: error calling GET")
                print(error!)
                completion(nil)
                return
            }
            // 옵셔널 바인딩
            guard let safeData = data else {
                print("Error: Did not receive data")
                completion(nil)
                return
            }
            // HTTP 200번대 정상코드인 경우만 다음 코드로 넘어감
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed")
                completion(nil)
                return
            }

            if let data = data {
                let jsonDecoder = JSONDecoder()

                let searchLocal = try! jsonDecoder.decode(SearchLocation.self, from: data)
                completion(searchLocal)
            }
        }.resume()
    }

    /// 주소 검색 API는 지번, 도로명를 질의어로 사용해서 주소 정보를 검색합니다. 검색 결과로 주소 목록과 세부 정보를 JSON 형태로 반환합니다.
    /// - Parameters:
    ///   - address: 주소
    ///   - completion: 경도 및 위도
    func fetchCoordinate(searchAddress: String, completion: @escaping (SearchCoordinate?) -> Void) {
        let url = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode"
        let address = searchAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = URL(string: "\(url)?query=\(address)")!

        let clientId = Bundle.main.object(forInfoDictionaryKey: "NMFClientId") as! String
        let clientSecret = Bundle.main.object(forInfoDictionaryKey: "NMFClientSecret") as! String

        var request = URLRequest(url: urlString)
        request.httpMethod = "GET"
        request.setValue(clientId, forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.setValue(clientSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Error: error calling GET")
                print(error!)
                completion(nil)
                return
            }
            // 옵셔널 바인딩
            guard let safeData = data else {
                print("Error: Did not receive data")
                completion(nil)
                return
            }
            // HTTP 200번대 정상코드인 경우만 다음 코드로 넘어감
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed")
                completion(nil)
                return
            }

            if let data = data {
                let jsonDecoder = JSONDecoder()

                let searchCoordinate = try! jsonDecoder.decode(SearchCoordinate.self, from: data)
                completion(searchCoordinate)
            }
        }.resume()
    }
    
    
    // 카카오 키워드로 주소 검색하기
    func fetchKakaoSearchLocation(searchWord: String, completion: @escaping (KakaoSearchLocation?) -> Void) {
        let url = "https://dapi.kakao.com/v2/local/search/keyword"
        let word = searchWord.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = URL(string: "\(url)?query=\(word)")!

        let kakaoKey = Bundle.main.object(forInfoDictionaryKey: "KakaoAK") as! String

        var request = URLRequest(url: urlString)
        request.httpMethod = "GET"
        request.setValue(kakaoKey, forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Error: error calling GET")
                print(error!)
                completion(nil)
                return
            }
            // 옵셔널 바인딩
            guard let safeData = data else {
                print("Error: Did not receive data")
                completion(nil)
                return
            }
            // HTTP 200번대 정상코드인 경우만 다음 코드로 넘어감
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed")
                completion(nil)
                return
            }

            if let data = data {
                let jsonDecoder = JSONDecoder()

                let kakaoSearchLocation = try! jsonDecoder.decode(KakaoSearchLocation.self, from: data)
                completion(kakaoSearchLocation)
            }
        }.resume()
    }
}
