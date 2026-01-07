import SwiftUI

enum ExerciseObj: String, CaseIterable {
    case running
    case golf
    case basketball
    case swimming
    case baseball
    case yoga
    case weight_training
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
        case .weight_training:
                "웨이트 트레이닝"
            case .cycling:
                "자전거"
            case .soccer:
                "축구"
            case .tennis:
                "테니스"
        }
    }
    
    // TODO: 서버 String과 매칭시키는 함수
    static func matchingExercise(_ exercise: String) -> ExerciseObj {
        switch exercise {
            case "RUNNING":
                .running
            case "BASEBALL":
                .baseball
            case "BASKETBALL":
                .basketball
            case "CYCLING":
                .cycling
            case "GOLF":
                .golf
            case "SOCCER":
                .soccer
            case "SWIMMING":
                .swimming
            case "WEIGHT_TRAINING":
                .weight_training
            case "TENNIS":
                .tennis
            case "YOGA":
                .yoga
            default:
                .running // default running
        }
    }
}
