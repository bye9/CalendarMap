//
//  SearchModel.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/03/06.
//

import Foundation

// MARK: - SearchLocal
/**
 - lastBuildDate: 검색 결과를 생성한 시간 ("Mon, 06 Mar 2023 22:57:38 +0900")
 - total: 총 검색 결과 개수 (5)
 - start: 검색 시작 위치 (1)
 - display: 한 번에 표시할 검색 결과 개수 (5)
 */
struct SearchLocal: Codable {
    let lastBuildDate: String
    let total, start, display: Int
    let items: [Item]
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
}

