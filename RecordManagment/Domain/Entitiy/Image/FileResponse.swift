//
//  FileResponse.swift
//  RecordManagment
//
//  Created by 김용해 on 9/17/25.
//

import Foundation

struct FileResponse: Codable {
    let statusCode: Int
    let code: String
    let message: String
    let data: FileUrls?
}

struct FileUrls: Codable {
    let fileUrls: [String]
}
