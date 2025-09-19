//
//  CalenderRecord.swift
//  RecordManagment
//
//  Created by 김용해 on 9/17/25.
//

import Foundation

struct CalenderRecord: Codable {
    let statusCode: Int
    let code: String
    let message: String
    let data: CalenderData?
}


struct CalenderData: Codable {
    let year: Int
    let month: Int
    let monthlyRecords: [AllRecord]?
}

struct AllRecord: Codable {
    let date: [Int]
    let records: [DetailRecord]
}

struct DetailRecord: Codable {
    let id: String
    let type: String
}
