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
        @Published var isGrantAlert: Bool = false
        let noticeService: NotificationService = .shared
        let useCase: SectionOnBoardingUseCase
        init(useCase: SectionOnBoardingUseCase) {
            self.useCase = useCase
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
        func requestPermisson() async -> Bool {
             let grant = await noticeService.requestNotificationPermission()
             return grant
        }
        
        // TODO: 앱 설정에서 권한 허용 시점에 grant 변경
        func checkPermission() async {
            let grant = await noticeService.getNotificationAuthorizationStatus()
            switch grant {
                case .authorized, .provisional, .ephemeral:
                    self.isGrant = true
                default:
                    self.isGrant = false
            }
        }
        
        // TODO: 앱 권한이 없을 경우 앱 세팅으로 보내는 함수
        func moveAppSetting() async {
            await noticeService.openAppSettings()
        }
        
        // TODO: OnBoarding 전달 함수
        func completeOnBoarding() async -> UserState {
            guard let onBoarding = await makeOnBoardingDTO() else { return .register }
            let result = await useCase.onBoardingFetchingComplete(dto: onBoarding)
            
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
            return OnBoardingDTO(
                nickName: name,
                mainRecordType: currentRecord.localizedString(),
                birthDate: Date.onBoardingFormet(selectedDate),
                goalDays: selectGoal.localizedInt(),
            )
        }
    }
}
