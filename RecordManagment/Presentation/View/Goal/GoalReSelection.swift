import SwiftUI

struct GoalReSelection: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject private var vm: SectionView.ViewModel = .init(
        useCase: SectionOnBoardingUseCase(
            repository: DefaultSectionRepository()
        ),
        firstOnBoarding: false
    )
    
    var body: some View {
        VStack {
            CustomProgress(value: vm.currentPage.rawValue + 1.0, total: 2)
            switch vm.currentPage {
                case .record:
                    SectionOneView(currentRecord: $vm.currentRecord)
                case .goal:
                    SectionFourView(selectedGoal: $vm.selectGoal, currentProgress: .constant(.goal))
            }
            
            Button(action: {
                next(vm.currentPage) {
                    coordinator.push(.finalOnBoarding(message: nil, sm: vm))
                }
            }, label: {
                Text("다음")
                    .typography(.p16Medium)
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(isNextDisabled ? Color.Primary.lighter() : Color.Primary.main())
                    .foregroundColor(isNextDisabled ? Color.Primary.light() : .white)
                    .cornerRadius(8)
            })
            .disabled(isNextDisabled)
        }
        .padding()
    }
}


// MARK: DATA Area
extension GoalReSelection {
    enum CurrentPage: Double, CaseIterable {
        case record
        case goal
        
        static var totalPage: Double {
            Double(allCases.count)
        }
    }
    
    func next(_ current: CurrentPage, completion: (() -> Void)? = nil) {
        if current == CurrentPage.allCases.last {
            completion?()
        }else {
            withAnimation {
                vm.currentPage = CurrentPage.allCases[Int(current.rawValue + 1.0)]
            }
        }
    }
    
    var isNextDisabled: Bool {
        switch vm.currentPage {
            case .record:
                vm.currentRecord == .none
            case .goal:
                vm.selectGoal == .none
        }
    }
}

#Preview {
    NavigationStack {
        GoalReSelection()
            .environmentObject(Coordinator())
    }
}

