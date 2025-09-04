//
//  SectionView+ViewModel.swift
//  RecordManagment
//
//  Created by 김용해 on 9/2/25.
//

import SwiftUI
import Combine

extension SectionView {
    class ViewModel: ObservableObject {
        @Published var currentProgress: ProgressPage = .record
        @Published var currentRecord: Record = .none
        @Published var name: String = ""
        @Published var isValidName: Bool = false
        @Published var selectGoal: SectionFourView.GoalTypes = .none
        @Published var isGrant: Bool? = nil
        
        let NoticeService: NotificationService = .init()
        
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
                .dropFirst()
                .map { name -> Bool in
                    let isVaild = !name.isEmpty && name.range(of: "^[a-zA-Z0-9가-힣]+$", options: .regularExpression) != nil
                    
                    return isVaild
                }
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }
        
        
        // TODO: Notification 권한 허용 함수
        @MainActor
        func requestPermisson() async {
             let grant = await NoticeService.requestNotificationPermission()
             self.isGrant = grant
        }
    }
}
