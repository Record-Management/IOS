import Foundation

enum SeedStep {
    case stage1
    case stage2
    case stage3
    case stage4
    case none
    case tutorial
    
    // TODO: 무럭이 이미지 분류
    var getMainIcon: String {
        switch self {
            case .stage1, .tutorial:
                "MainStep01"
            case .stage2:
                "MainStep02"
            case .stage3:
                "MainStep03"
            case .stage4:
                "MainStep04"
            case .none:
                "MainStepNone"
        }
    }
    
    // TODO: 단계별 구조
    var currentStep: [Stage] {
        switch self {
        case .stage1:
            [
                Stage(iconName: "Stage01", point: true),
                Stage(iconName: nil, point: false),
                Stage(iconName: nil, point: false),
                Stage(iconName: nil, point: false),
            ]
        case .stage2:
            [
                Stage(iconName: "Stage01", point: false),
                Stage(iconName: "Stage02", point: true),
                Stage(iconName: nil, point: false),
                Stage(iconName: nil, point: false),
            ]
        case .stage3:
            [
                Stage(iconName: "Stage01", point: false),
                Stage(iconName: "Stage02", point: false),
                Stage(iconName: "Stage03", point: true),
                Stage(iconName: nil, point: false),
            ]
        case .stage4:
            [
                Stage(iconName: "Stage01", point: false),
                Stage(iconName: "Stage02", point: false),
                Stage(iconName: "Stage03", point: false),
                Stage(iconName: "Stage04", point: true),
            ]
        case .none:
            [
                Stage(iconName: nil, point: false),
                Stage(iconName: nil, point: false),
                Stage(iconName: nil, point: false),
                Stage(iconName: nil, point: false),
            ]
            
        case .tutorial:
            [
                Stage(iconName: "Stage01", point: true),
                Stage(iconName: "Stage02", point: false),
                Stage(iconName: "Stage03", point: false),
                Stage(iconName: "Stage04", point: false),
            ]
        }
    }
    
    // TODO: 툴팁 Text 내용 분류
    var currentToolTipText: String? {
        switch self {
        case .stage1:
            "성장 1단계"
        case .stage2:
            "성장 2단계"
        case .stage3:
            "성장 3단계"
        case .stage4:
            "성장 4단계"
        case .none:
            nil
        case .tutorial:
            "성장 N단계"
        }
    }
}


// TODO: Data Structure
extension SeedStep {
    struct Stage {
        let iconName: String?
        let point: Bool
    }
}
