import SwiftUI

struct SectionView: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject private var vm: SectionView.ViewModel = .init()
    
    var isNextDisabled: Bool {
        switch vm.currentProgress {
        case .record:
            return vm.currentRecord == .none
        case .name:
            return !vm.isValidName
        case .birth:
            return false
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
                        SectionThreeView(selectedDate: $vm.selectedDate, currentProgress: $vm.currentProgress)
                    case .goal:
                        SectionFourView(selectedGoal: $vm.selectGoal, currentProgress: $vm.currentProgress)
                    case .notification:
                        SectionFiveView(currentProgress: $vm.currentProgress)
                }
                
                Button(action: {
                    // 알림 허용 기능
                    if vm.currentProgress == .notification {
                        Task {
                            await vm.requestPermisson()
                        }
                    } else {
                        next(vm.currentProgress)
                    }
                }, label: {
                    Text(vm.currentProgress == .notification ? "완료하기" : "다음")
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(isNextDisabled ? Color(hex: "#FFF0E1") : Color(hex: "#FF9528"))
                        .foregroundColor(isNextDisabled ? Color(hex: "#FFCA93") : .white)
                        .cornerRadius(8)
                })
                .disabled(isNextDisabled)
            }
            .padding()
            .onChange(of: vm.isGrant) { grant in
                next(vm.currentProgress) {
                    // 모든 Progress 를 빠져나갑니다
                    if let grant = grant {
                        if grant {
                            coordinator.push(.finalOnBoarding(message: nil, sm: vm))
                        } else {
                            coordinator.push(.finalOnBoarding(message: "알림 설정이 거부되었습니다.", sm: vm))
                        }
                    }
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
    }
}
