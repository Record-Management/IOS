import SwiftUI

struct GoalReSelection: View {
    @EnvironmentObject var coordinator: Coordinator
    let store: OnBoardingStore
    
    init(store: OnBoardingStore) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            CustomProgress(value: store.state.currentPage.rawValue + 1.0, total: 2)
            switch store.state.currentPage {
                case .record:
                    SectionOneView()
                case .goal:
                    SectionFourView()
            }
            
            Button(action: {
                next(store.state.currentPage) {
                    coordinator.push(.finalOnBoarding(message: nil))
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
        .onAppear {
            store.send(.bindingIsReSelection(true))
        }
        .padding()
        .environment(store) // Inject OnBoardingStore for child views
        .navigationBarBackButtonHidden(true)
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
                store.send(.bindingCurrentPage(CurrentPage.allCases[Int(current.rawValue + 1.0)]))
            }
        }
    }
    
    var isNextDisabled: Bool {
        switch store.state.currentPage {
            case .record:
                store.state.currentRecord == .none
            case .goal:
                store.state.selectGoal == .none
        }
    }
}
