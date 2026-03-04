import SwiftUI

struct SectionView: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject private var vm: SectionView.ViewModel = .init(
        useCase: SectionOnBoardingUseCase(
            repository: DefaultSectionRepository()
        )
    )
    
    var isNextDisabled: Bool {
        switch vm.currentProgress {
        case .record:
            return vm.currentRecord == .none
        case .name:
            return !vm.isValidName
        case .birth:
            let isActiveDate = Calendar.current.date(byAdding: .year, value: -4, to: Date())
            return vm.selectedDate > isActiveDate ?? .now ? true : false
        case .goal:
            return vm.selectGoal == .none
        case .notification:
            return false
        }
    }
    
    var body: some View {
        VStack {
            CustomProgress(value: vm.currentProgress.rawValue + 1.0, total: ProgressPage.totalPage)
            VStack {
                switch vm.currentProgress {
                    case .record:
                        SectionOneView(currentRecord: $vm.currentRecord)
                    case .name:
                        SectionTwoView(
                            name: $vm.name,
                            currentProgress: $vm.currentProgress,
                            isValidName: $vm.isValidName
                        )
                    case .birth:
                        SectionThreeView(selectedDate: $vm.selectedDate, currentProgress: $vm.currentProgress, birthPartSkip: $vm.birthPartSkip)
                    case .goal:
                        SectionFourView(
                            selectedGoal: $vm.selectGoal,
                            currentProgress: $vm.currentProgress,
                            isReSelection: $vm.isReSelection,
                            currentPage: $vm.currentPage
                        )
                    case .notification:
                        SectionFiveView(currentProgress: $vm.currentProgress)
                }
                
                Button(vm.currentProgress == .notification ? "완료하기" : "다음") {
                    // 알림 허용 기능
                    if vm.currentProgress == .notification {
                        Task {
                            let askedNotice = UserDefaults.standard.bool(forKey: UserDefaultKey.didAskNotificationPermission)
                            
                            if askedNotice {
                                let grant = await vm.requestPermisson()
                                if !grant {
                                    vm.isGrantAlert = true
                                }else {
                                    vm.isGrant = grant
                                }
                            } else {
                                let grant = await vm.requestPermisson()
                                vm.isGrant = grant
                            }
                        }
                    } else {
                        next(vm.currentProgress)
                    }
                }
                .seedDaysButtonStyle(type: isNextDisabled ? .normal : .success, state: .primary)
                .disabled(isNextDisabled)
            }
            .padding()
            .onChange(of: vm.isGrant) {
                next(vm.currentProgress) {
                    // 모든 Progress 를 빠져나갑니다
                    if let grant = vm.isGrant {
                        if grant {
                            coordinator.push(.finalOnBoarding(message: nil, sm: vm))
                        } else {
                            coordinator.push(.finalOnBoarding(message: "알림 설정이 거부되었습니다.", sm: vm))
                        }
                    }
                }
            }
            .alert("알림 권한", isPresented: $vm.isGrantAlert, actions: {
                Button("설정으로 이동") {
                    Task {
                        await vm.moveAppSetting()
                    }
                }
                Button("취소", role: .cancel) {
                    vm.isGrant = false
                }
            }, message: {
                Text("알림 권한을 허용하면 알림을 받을 수 있어요")
                    .typography(.p14Medium)
            })
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task {
                    await vm.checkPermission()
                }
            }
        }
    }
}

extension SectionView {
    
    /// ** Page 진행도를 위한 data 구조
    /// - enum: 각 Double값을 줌으로서 순차적인 진행 Page적용
    /// - next: 다음 페이지 이동
    /// - pop: 전 페이지 이동
    enum ProgressPage: Double, CaseIterable {
        case record
        case name
        case birth
        case goal
        case notification
        
        
        static var totalPage: Double {
            Double(allCases.count)
        }
    }
    
    func next(_ current: ProgressPage, completion: (() -> Void)? = nil) {
        if current == ProgressPage.allCases.last {
            completion?()
        }else {
            withAnimation {
                vm.currentProgress = ProgressPage.allCases[Int(current.rawValue + 1.0)]
            }
        }
    }
}

#Preview {
    NavigationStack {
        SectionView()
            .environmentObject(Coordinator())
    }
}
