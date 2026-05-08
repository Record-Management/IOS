import SwiftUI

extension HabitRecordView {
    @MainActor
    final class ViewModel: ObservableObject {
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
        @Published var isMainRecord: Bool = false
        @Published var currentMainRecord: Bool = false
        @Published var error: RecordError? = nil
        
        var recordId: String = ""
        let useCase: HabitRecordUseCase

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
            self.isMainRecord = habitInfo.isMainRecord
        }
        
        // TODO: 습관 기록 작성 함수
        func create(current date: Date) async -> Bool {

            let form = HabitRequestBody(
                habitType: habit.imageName,
                notificationEnabled: isToggle,
                notificationTime: isToggle ? Date.intergrationDateFormat(time, format: "HH:mm") : nil,
                memo: memo.isEmpty ? nil : memo,
                recordDate: Date.onBoardingFormet(date),
                isMainRecord: self.isMainRecord || isMainRecordToggle
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
        
        func update() async -> Bool {
            let form = HabitRequestBody(
                habitType: habit.imageName,
                notificationEnabled: isToggle,
                notificationTime: isToggle ? Date.intergrationDateFormat(time, format: "HH:mm") : nil,
                memo: memo.isEmpty ? nil : memo,
                recordDate: nil,
                isMainRecord: isMainRecordToggle || isMainRecord
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


// MARK: - 습관 Case 분리
extension HabitRecordView.ViewModel {
    enum HabitMainStatus {
        case initialFirst   // 처음 작성, 자동으로 메인 (토글 비노출)
        case secondarySub   // 다른 메인이 존재하거나 현재 서브 기록임 (토글 노출)
        case activeMain     // 이미 본인이 메인 기록임 (토글 비노출)
        case none           // 메인 기록 방식이 습관이 아님
    }
    
    func getHabitMainStatus(originalRecord: SeedType) -> HabitMainStatus {
        guard originalRecord == .habit else { return .none }
        
        if method == .create {
            return currentMainRecord ? .secondarySub : .initialFirst
        } else {
            return isMainRecord ? .activeMain : .secondarySub
        }
    }
}
