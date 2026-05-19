import Foundation

final class Constant {
    /// 플로팅 버튼 관련 상수 모음
    enum Floating {
        /// 메뉴의 너비 비율 (화면 너비의 0.4배)
        static let menuWidthRatio: CGFloat = 0.4
        /// 메뉴 배경의 모서리 둥글기
        static let cornerRadius: CGFloat = 12
        /// 메뉴 배경 그림자 반경
        static let shadowRadius: CGFloat = 10
        /// 메뉴 배경 그림자 투명도
        static let shadowOpacity: Double = 0.1
        /// 메뉴 배경 그림자 Y축 오프셋
        static let shadowY: CGFloat = 5
        /// 버튼과 메뉴 사이의 간격
        static let menuSpacing: CGFloat = 10
        /// 메뉴 전환 애니메이션 스케일 비율
        static let transitionScale: CGFloat = 0.8
        /// 기본 애니메이션 지속 시간
        static let animationDuration: Double = 0.25
        /// 메뉴 아이템 내부 요소 간격 (아이콘과 텍스트 사이)
        static let itemSpacing: CGFloat = 12
        /// 메뉴 아이템 가로 패딩
        static let itemHorizontalPadding: CGFloat = 16
        /// 메뉴 아이템 세로 패딩
        static let itemVerticalPadding: CGFloat = 15
        /// 배경 딤(Dim) 처리 투명도
        static let dimOpacity: Double = 0.5
        /// 버튼 확장 시 회전 각도 (Plus -> Close)
        static let rotationDegrees: Double = 45
    }
}

