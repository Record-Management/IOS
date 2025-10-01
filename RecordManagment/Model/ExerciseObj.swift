import SwiftUI

enum ExerciseObj: String, CaseIterable {
    case running
    case golf
    case basketball
    case swimming
    case baseball
    case yoga
    case weights
    case cycling
    case soccer
    case tennis
    
    var id: String {
        self.rawValue
    }
    
    // TODO: Image Assets 각 이름
    var imageName: String {
        self.rawValue.uppercased()
    }
    
    func getName() -> String {
        switch self {
            case .running:
                "러닝"
            case .golf:
                "골프"
            case .basketball:
                "농구"
            case .swimming:
                "수영"
            case .baseball:
                "야구"
            case .yoga:
                "요가"
            case .weights:
                "웨이트 트레이닝"
            case .cycling:
                "자전거"
            case .soccer:
                "축구"
            case .tennis:
                "테니스"
        }
    }
}
