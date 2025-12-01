import SwiftUI

extension HabitRecordView {
    class ViewModel: ObservableObject {
        @Published var habit: HabitObj
        @Published var sheet: Bool = false
        @Published var memo: String = ""
        @Published var method: RecordMethod
        @Published var isDismiss: Bool = false
        @Published var isToggle: Bool = false
        @Published var isMainRecordToggle: Bool = false
        @Published var time: Date = Calendar.current.date(from: DateComponents(
            year: Calendar.current.component(.year, from: .now),
            month: Calendar.current.component(.month, from: .now),
            day: Calendar.current.component(.day, from: .now),
            hour: 10,
            minute: 0
        )) ?? .now
        @Published var isOnDatePicker: Bool = false
        @Published var error: RecordError? = nil
        @Published var isMainRecord: Bool? = nil 
        @Published var currentMainRecord: Bool = false
        
        let useCase: HabitRecordUseCase
        var recordId: String = ""
        
        init(habit: HabitObj, method: RecordMethod, useCase: HabitRecordUseCase) {
            self.habit = habit
            self.method = method
            self.useCase = useCase
        }
        
        init(habitInfo: HabitResponse, method: RecordMethod, useCase: HabitRecordUseCase) {
            recordId = habitInfo.base.id
            self.memo = habitInfo.memo ?? ""
            self.habit = HabitObj.matchingHabitObj(habitInfo.habitType)
            self.isToggle = habitInfo.notificationEnabled
            self.time = Date.convertTimeForIntArray(habitInfo.notificationTime ?? []) ?? .now
            self.method = method
            self.useCase = useCase
            self.isMainRecordToggle = habitInfo.isMainRecord
            self.currentMainRecord = !habitInfo.isMainRecord
        }
        
        // TODO: 습관 기록 작성 함수
        @MainActor
        func create(current date: Date) async -> Bool {
            
            let form = HabitRequestBody(
                habitType: habit.imageName,
                notificationEnabled: isToggle,
                notificationTime: isToggle ? Date.intergrationDateFormat(time, format: "HH:mm") : nil,
                memo: memo.isEmpty ? nil : memo,
                recordDate: Date.onBoardingFormet(date),
                isMainRecord: self.isMainRecord != nil ? isMainRecord : nil
            )
            
            let result = await useCase.create(request: form)
            
            switch result {
            case .success(let res):
                if res.code == "E40409" {
                    error = .habitLimit
                    return false
                } else if res.code == "E40410" {
                    error = .totalLimit
                    return false
                }
                
                return true
            case .failure(let err):
                debugPrint("습관 기록 작성 실패: \(err.localizedDescription)")
                return false
            }
        }
        
        @MainActor
        func update() async -> Bool {
            let form = HabitRequestBody(
                habitType: habit.imageName,
                notificationEnabled: isToggle,
                notificationTime: isToggle ? Date.intergrationDateFormat(time, format: "HH:mm") : nil,
                memo: memo.isEmpty ? nil : memo,
                recordDate: nil,
                isMainRecord: self.isMainRecord != nil ? isMainRecord : isMainRecordToggle
            )

            let result = await useCase.update(form: form, recordId: recordId)
            
            switch result {
            case .success(let res):
                debugPrint("수정 : \(res)")
                return true
            case .failure(let err):
                debugPrint("습관 기록 수정 : \(err)")
                return false
            }
        }
        
        @MainActor
        func delete() async -> Bool {
            let result = await useCase.delete(recordId: recordId)
            
            switch result {
                case .success(_):
                    return true
                case .failure(let err):
                    debugPrint("기록 삭제 : \(err)")
                    return false
            }
        }
    }
}
