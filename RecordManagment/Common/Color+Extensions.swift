//
//  ColorExtensions.swift
//  RecordManagment
//
//  Created by 김용해 on 8/13/25.
//

import SwiftUI

// TODO: init Hex Color Setting
extension Color {
    init(hex: String) {
        // # 기호 및 공백 제거
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0

        // Hex 값을 스캔하여 UInt64로 변환
        guard scanner.scanHexInt64(&hexNumber) else {
            self.init(UIColor.clear) // 실패 시 투명색으로 초기화
            return
        }
        
        // 각 R, G, B 채널 값을 0-1 사이의 Double로 변환
        let r = Double((hexNumber & 0xff0000) >> 16) / 255
        let g = Double((hexNumber & 0x00ff00) >> 8) / 255
        let b = Double(hexNumber & 0x0000ff) / 255
        
        self.init(red: r, green: g, blue: b)
    }
}
