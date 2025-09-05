//
//  SectionView+ViewModel.swift
//  RecordManagment
//
//  Created by 김용해 on 9/2/25.
//

import SwiftUI
import Combine

extension SectionView {
    
    @MainActor
    class ViewModel: ObservableObject {
        @Published var currentProgress: ProgressPage = .record
        @Published var currentRecord: Record = .none
        @Published var name: String = ""
        @Published var isValidName: Bool = false
        @Published var selectGoal: SectionFourView.GoalTypes = .none
        @Published var isGrant: Bool? = nil
        @Published var selectedDate: Date = .now
        
        let noticeService: NotificationService = .init()
        let networkManager: SectionNetworkManager = .init()
        
        init() {
            // TODO: NAME Subscriber 선언
            getNameSubscriber()
        }
        
        private var cancellables: Set<AnyCancellable> = []
        
        // TODO: 온보딩 Name 부분 구독 함수
        private func getNameSubscriber() {
            getNamePublisher()
                .sink { [weak self] val in
                    withAnimation(.smooth) {
                        self?.isValidName = val
                    }
                }
                .store(in: &cancellables)
        }
        
        // TODO: 온보딩 Name 부분 Publisher 함수
        private func getNamePublisher() -> AnyPublisher<Bool,Never> {
            $name
                .debounce(for: 0.2, scheduler: RunLoop.main)
                .map { name -> Bool in
                    if name.isEmpty { return false }
                    guard name.count <= 6 else { return false }
                    
                    return name.range(of: "^[a-zA-Z0-9가-힣]+$", options: .regularExpression) != nil
                }
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }
        
        
        // TODO: Notification 권한 허용 함수
        func requestPermisson() async {
             let grant = await noticeService.requestNotificationPermission()
             self.isGrant = grant
        }
        
        // TODO: OnBoarding 전달 함수
        func completeOnBoarding() async -> UserState {
            guard let onBoarding = await makeOnBoardingDTO() else { return .register }
            
            let result = await networkManager.onBoardingComplete(onBoardingDTO: onBoarding)
            
            switch result {
                case .success(let success):
                    print(success)
                    return .main
                case .failure(let failure):
                    print(failure)
                    return .register
            }
        }
        
        // TODO: 온보딩 객체 생성 함수
        func makeOnBoardingDTO() async -> OnBoardingDTO? {
            // 저장된 값 확인
            guard let isGrant, isGrant else { return nil }
            
            // 최신 권한 상태 확인
            let granted = await noticeService.checkNotificationAuthorizationStatus()
            guard granted else { return nil }
            
            return OnBoardingDTO(
                nickName: name,
                mainRecordType: currentRecord.localizedString(),
                birthDate: Date.onBoardingFormet(selectedDate),
                goalDays: selectGoal.localizedInt(),
                notificationEnabled: granted
            )
        }
    }
}
