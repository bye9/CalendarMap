//
//  SearchModel.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/03/06.
//

import Foundation

// MARK: - SearchLocation
/**
 - lastBuildDate: 검색 결과를 생성한 시간 ("Mon, 06 Mar 2023 22:57:38 +0900")
 - total: 총 검색 결과 개수 (5)
 - start: 검색 시작 위치 (1)
 - display: 한 번에 표시할 검색 결과 개수 (5)
 */
struct SearchLocation: Codable {
    let lastBuildDate: String
    let total, start, display: Int
    let items: [Item]
    
    init(lastBuildDate: String, total: Int, start: Int, display: Int, items: [Item]) {
        self.lastBuildDate = lastBuildDate
        self.total = total
        self.start = start
        self.display = display
        self.items = items
    }
}

// MARK: - Item
/**
 - title: 업체, 기관의 이름 ("<b>상암중</b>학교")
 - link: 업체, 기관의 상세 정보 URL ("http://www.sangam.ms.kr/")
 - category: 업체, 기관의 분류 정보 ("교육, 학문>중학교"
 - description: 업체, 기관에 대한 설명 ("")
 - telephone: 값을 반환하지 않는 요소 ("")
 - address: 업체, 기관명의 지번 주소 ("서울특별시 마포구 상암동 1657")
 - roadAddress: 업체, 기관명의 도로명 주소 ("서울특별시 마포구 상암산로1길 26 상암중학교")
 - mapx: 업체, 기관이 위치한 장소의 x좌표 ("301958")
 - mapy: 업체, 기관이 위치한 장소의 y좌표 ("553591")
 */
struct Item: Codable {
    let title, link, category, description: String
    let telephone, address, roadAddress: String
    let mapx, mapy: String
    
    init(title: String, link: String, category: String, description: String, telephone: String, address: String, roadAddress: String, mapx: String, mapy: String) {
        self.title = title
        self.link = link
        self.category = category
        self.description = description
        self.telephone = telephone
        self.address = address
        self.roadAddress = roadAddress
        self.mapx = mapx
        self.mapy = mapy
    }
}

// MARK: - SearchCoordinate
/**
 - status: 검색 결과 상태 코드 ("OK")
 - meta: 검색 메타 데이터
 - addresses: 주소 검색 결과 목록
 - errorMessage: 예외 발생 시 메시지
 */
struct SearchCoordinate: Codable {
    let status: String
    let meta: Meta
    let addresses: [Address]
    let errorMessage: String
    
    init(status: String, meta: Meta, addresses: [Address], errorMessage: String) {
        self.status = status
        self.meta = meta
        self.addresses = addresses
        self.errorMessage = errorMessage
    }
}

// MARK: - Address
/**
 - roadAddress: 도로명 주소 ("서울특별시 마포구 상암산로1길 26 상암중학교")
 - jibunAddress: 지번 주소 ("서울특별시 마포구 상암동 1657 상암중학교")
 - englishAddress: 영어 주소 ("26, Sangamsan-ro 1-gil, Mapo-gu, Seoul, Republic of Korea")
 - addressElements: 주소를 이루는 요소들
 - x, y: 경도 및 위도 ("x": "126.8878807", "y": "37.5788596")
 - distance: 검색 중심 좌표로부터의 거리
 */
struct Address: Codable {
    let roadAddress, jibunAddress, englishAddress: String
    let addressElements: [AddressElement]
    let x, y: String
    let distance: Int
}

// MARK: - AddressElement
struct AddressElement: Codable {
    let types: [String]
    let longName, shortName, code: String
}

// MARK: - Meta
struct Meta: Codable {
    let totalCount, page, count: Int
}
