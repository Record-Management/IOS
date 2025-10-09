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

extension Color {
    struct Gray {
        static func _900() -> Color {
            Color(hex: "#212121")
        }
        static func _800() -> Color {
            Color(hex: "#424242")
        }
        static func _700() -> Color {
            Color(hex: "#616161")
        }
        static func _600() -> Color {
            Color(hex: "#757575")
        }
        static func _500() -> Color {
            Color(hex: "#9E9E9E")
        }
        static func _400() -> Color {
            Color(hex: "#BDBDBD")
        }
        static func _300() -> Color {
            Color(hex: "#E0E0E0")
        }
        static func _200() -> Color {
            Color(hex: "#EEEEEE")
        }
        static func _100() -> Color {
            Color(hex: "#F5F5F5")
        }
        static func _50() -> Color {
            Color(hex: "#FAFAFA")
        }
        static func _0() -> Color {
            Color(hex: "#FFFFFF")
        }
    }
    struct Primary {
        static func main() -> Color {
            Color(hex: "#FF9528")
        }
        static func light() -> Color {
            Color(hex: "#FFCA93")
        }
        static func lighter() -> Color {
            Color(hex: "#FFF0E1")
        }
    }
    struct Error {
        static func main() -> Color {
            Color(hex: "#FF3B30")
        }
    }
    struct Accent {
        static func main() -> Color {
            Color(hex: "#FE6449")
        }
    }
}
