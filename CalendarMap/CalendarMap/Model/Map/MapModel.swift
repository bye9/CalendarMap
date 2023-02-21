//
//  MapModel.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/02/21.
//

import Foundation

// MARK: - Map
struct Map: Codable {
    let status: Status
    let results: [Result]
}

// MARK: - Status
struct Status: Codable {
    let code: Int
    let name, message: String
}

// MARK: - Result
struct Result: Codable {
    let name: String
    let code: Code
    let region: Region
    let land: Land?
}

// MARK: - Code
struct Code: Codable {
    let id, type, mappingID: String

    enum CodingKeys: String, CodingKey {
        case id, type
        case mappingID = "mappingId"
    }
}

/**
 area0: 국가 코드 최상위 도메인 두 자리 (kr)
 area1: 행정 구역 단위 명칭 1 (서울특별시)
 area2: 행정 구역 단위 명칭 2 (마포구)
 area3: 행정 구역 단위 명칭 3 (상암동)
 area4: 행정 구역 단위 명칭 4 (~리)
 
 */
// MARK: - Region
struct Region: Codable {
    let area0, area1, area2, area3, area4: Area
}

// MARK: - Area
struct Area: Codable {
    let name: String
    let coords: Coords
}

// MARK: - Coords
/**
 center: 행정 구역의 중심 좌표
 */
struct Coords: Codable {
    let center: Center
}

/**
 crs: 좌표계 코드
 x: 경도(longitude)
 y: 위도(latitude)
 */
// MARK: - Center
struct Center: Codable {
    let crs: String
    let x, y: Double
}

// MARK: - Land
struct Land: Codable {
    let name: String?
    let type, number1, number2: String
    let addition0, addition1, addition2, addition3, addition4: Addition
    let coords: Coords
}

// MARK: - Addition
struct Addition: Codable {
    let type, value: String
}
