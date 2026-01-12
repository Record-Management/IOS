# 씨드데이 (SeedDay) - Record Management iOS App
<br/>
<img width=100 height=100 src="https://github.com/user-attachments/assets/33dca495-9c36-4cfc-a69f-8947b59f0390"/>
<br/>

## 1. 프로젝트 개요
**씨드데이**는 사용자의 꾸준한 기록을 통해 성장을 돕는 iOS 애플리케이션입니다. 사용자는 매일의 감정, 운동, 습관 등을 기록할 수 있으며, 설정한 목표를 달성해나가며 '하루 나무'를 키우는 시각적인 경험을 할 수 있습니다.

단순한 기록을 넘어, 사용자가 자신의 삶을 가꾸고 성장하는 즐거움을 느낄 수 있도록 설계되었습니다.

## 2. 주요 기능

- **소셜 로그인**: 카카오 및 Apple 계정을 통한 간편한 회원가입 및 로그인을 지원합니다.
- **온보딩**: 사용자 맞춤형 경험을 위해 초기 설정(닉네임, 주 기록 타입, 목표 설정 등) 과정을 안내합니다.
- **기록 관리**:
    - **하루 기록**: 그날의 감정, 생각, 사진을 함께 기록합니다.
    - **운동 기록**: 다양한 운동 종류(러닝, 웨이트 등)와 세부 항목(소모 칼로리, 시간, 걸음 수 등)을 기록합니다.
    - **습관 기록**: 만들고 싶은 습관을 등록하고, 알림 설정 및 달성 여부를 체크합니다.
- **메인 화면**:
    - 사용자의 목표 달성률에 따라 성장하는 '하루 나무'를 시각적으로 제공합니다.
    - 하단 시트(Bottom Sheet)를 통해 선택한 날짜의 기록을 확인하고 관리할 수 있습니다.
- **캘린더**: 월별/주별 캘린더를 통해 과거의 기록을 한눈에 볼 수 있으며, 기록 종류별 필터링 기능을 제공합니다.
- **목표 시스템**:
    - 사용자가 직접 목표 기간(10일, 20일, 30일)을 설정합니다.
    - 목표 달성 시 리포트를 제공하여 성취감을 고취합니다.
- **알림**: Firebase Cloud Messaging(FCM)을 활용하여 기록 알림, 목표 설정 알림, 시스템 공지 등 다양한 푸시 알림을 제공합니다.
- **설정**: 프로필 정보(닉네임, 생일) 수정, 알림 수신 여부 설정, 약관 확인 및 문의하기 등의 기능을 제공합니다.

## 3. 아키텍처

이 프로젝트는 **Clean Architecture**를 기반으로 설계되었으며, 각 계층은 다음과 같은 역할을 수행합니다.

- **Presentation Layer**:
    - **MVVM-C (Model-View-ViewModel-Coordinator)** 패턴을 적용했습니다.
    - **View**: SwiftUI를 사용하여 UI를 선언적으로 구성합니다.
    - **ViewModel**: View의 상태를 관리하고, UseCase를 통해 비즈니스 로직을 실행합니다.
    - **Coordinator**: 화면 전환 및 Navigation 로직을 중앙에서 관리하여 View의 의존성을 낮춥니다.
- **Domain Layer**:
    - **Entity**: 앱의 핵심 비즈니스 모델을 정의합니다. (e.g., `User`, `Record`, `Goal`)
    - **UseCase**: 특정 비즈니스 로직을 캡슐화합니다. ViewModel은 이 UseCase를 호출하여 작업을 수행합니다.
    - **Repository (Protocol)**: 데이터 소스에 대한 인터페이스를 정의하여 Data Layer와의 의존성을 분리합니다.
- **Data Layer**:
    - **Repository (Implementation)**: Domain Layer에 정의된 Repository 프로토콜을 구현합니다.
    - **Network**: `Alamofire`를 사용하여 서버와의 API 통신을 담당합니다.
    - **Data Source**: `Keychain` (토큰 관리), `UserDefaults` 등 로컬 데이터 처리를 담당합니다.

## 4. 사용된 기술 및 라이브러리

- **UI Framework**: `SwiftUI`
- **Concurrency**: `Async/Await` (Swift Concurrency)
- **Reactive Programming**: `Combine`
- **Networking**: `Alamofire`
- **Authentication**: `KakaoSDK`, `AuthenticationServices` (Sign in with Apple)
- **Push Notifications & Analytics**: `Firebase` (FCM, Analytics)
- **Dependency Management**: `Swift Package Manager`

## 5. 폴더 구조

```
RecordManagment/
├─── AppDelegate.swift         # Firebase, Notification 설정
├─── Analytics/                # Firebase Analytics 관리
├─── Assets.xcassets/          # 앱 아이콘, 이미지 등 리소스
├─── Data/
│    ├─── Repository/          # Domain의 Repository 프로토콜 구현체
│    └─── Network/             # 네트워크 통신(Alamofire, Manager)
├─── Domain/
│    ├─── Entity/              # 핵심 비즈니스 모델
│    ├─── Repository/          # 데이터 계층의 인터페이스 (Protocol)
│    └─── UseCase/             # 비즈니스 로직
├─── Extensions/
│    ├─── Common/              # Foundation, UIKit 클래스 확장
│    ├─── Components/          # 재사용 가능한 SwiftUI View 컴포넌트
│    └─── Modifier/            # ViewModifier 정의
├─── Presentation/
│    ├─── Coordinator/         # 화면 네비게이션 관리
│    ├─── View/                # SwiftUI 뷰
│    └─── ViewModel/           # 뷰의 상태 및 로직 관리
└─── Resources/
     └─── Font/                # 커스텀 폰트
```
