import Foundation

/// 로그인 인증 상태 열거 형
enum AuthState {
    case initialize // 초기 상태 ( splash )
    case login      // 로그인 화면
    case register   // 온보딩 화면
    case main       // 앱의 메인 화면
}
