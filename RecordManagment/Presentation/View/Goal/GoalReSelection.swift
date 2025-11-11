import SwiftUI

struct GoalReSelection: View {
    @EnvironmentObject var coordinator: Coordinator
    @State private var currentPage: CurrentPage = .record
    @State private var currentRecord: Record = .none
    @State private var goalType: SectionFourView.GoalTypes = .none
    var body: some View {
        VStack {
            CustomProgress(value: currentPage.rawValue + 1.0, total: 2)
            switch currentPage {
                case .record:
                    SectionOneView(currentRecord: $currentRecord)
                case .goal:
                    SectionFourView(selectedGoal: $goalType, currentProgress: .constant(.goal))
            }
            
            Button(action: {
                next(self.currentPage) {
                    
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
                self.currentPage = CurrentPage.allCases[Int(current.rawValue + 1.0)]
            }
        }
    }
    
    var isNextDisabled: Bool {
        switch currentPage {
            case .record:
                currentRecord == .none
            case .goal:
                goalType == .none
        }
    }
}

#Preview {
    NavigationStack {
        GoalReSelection()
            .environmentObject(Coordinator())
    }
}

