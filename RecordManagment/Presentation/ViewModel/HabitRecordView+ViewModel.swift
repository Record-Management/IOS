import SwiftUI

extension HabitRecordView {
    class ViewModel: ObservableObject {
        @Published var habit: HabitObj
        @Published var sheet: Bool = false
        @Published var memo: String = ""
        @Published var method: RecordMethod
        @Published var isDismiss: Bool = false
        @Published var isToggle: Bool = false
        @Published var time: Date = Calendar.current.date(from: DateComponents(
            year: Calendar.current.component(.year, from: .now),
            month: Calendar.current.component(.month, from: .now),
            day: Calendar.current.component(.day, from: .now),
            hour: 10,
            minute: 0
        )) ?? .now
        @Published var isOnDatePicker: Bool = false
        @Published var error: RecordError? = nil
        
        let useCase: HabitRecordUseCase
        
        init(habit: HabitObj, method: RecordMethod, useCase: HabitRecordUseCase) {
            self.habit = habit
            self.method = method
            self.useCase = useCase
        }
        
        // TODO: 습관 기록 작성 함수
        func create(current date: Date) async -> Bool {
            
            let form = HabitRequestBody(
                habitType: habit.imageName,
                notificationEnabled: isToggle,
                notificationTime: Date.intergrationDateFormat(time, format: "HH:mm"),
                memo: memo.isEmpty ? nil : memo,
                recordDate: Date.onBoardingFormet(date)
            )
            
            let result = await useCase.create(request: form)
            
            switch result {
            case .success(let res):
                if res.code == "E40407" {
                    error = .habitLimit
                    return false
                } else if res.code == "E40410" {
                    error = .totalLimit
                    return false
                }
                
                return true
            case .failure(let err):
                debugPrint("습관 기록 작성 실패: \(err)")
                return false
            }
        }
    }
}
