import Foundation

enum SeedStep {
    case stage1
    case stage2
    case stage3
    case stage4
    case none
    
    var getMainIcon: String {
        switch self {
            case .stage1:
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
