enum RecordError {
    case dailyLimit    // 하루 기록에 대한 제한
    case exerciseLimit // 운동 기록에 대한 제한
    case totalLimit    // 특정 날짜 기록 전체 제한
    
    func getTitle() -> String {
        switch self {
            case .dailyLimit:
                "오늘의 기록이 모두 채워졌어요."
            case .totalLimit:
                "오늘의 기록이 모두 채워졌어요."
            case .exerciseLimit:
                "오늘의 기록이 모두 채워졌어요."
        }
    }
    
    func getSubTitle() -> String {
        switch self {
            case .dailyLimit:
                "내일 다시 시도해 주세요"
            case .totalLimit:
                "내일 다시 시도해 주세요"
            case .exerciseLimit:
                "내일 다시 시도해 주세요"
        }
    }
}
