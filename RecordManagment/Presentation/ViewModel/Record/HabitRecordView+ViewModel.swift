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
        private let repository: any RecordRepository<HabitRequestBody, HabitDTO>

        init(habit: HabitObj, method: RecordMethod, repository: any RecordRepository<HabitRequestBody, HabitDTO>) {
            self.habit = habit
            self.method = method
            self.repository = repository
        }
        
        init(habitInfo: HabitResponse, method: RecordMethod, repository: any RecordRepository<HabitRequestBody, HabitDTO>) {
            recordId = habitInfo.base.id
            self.memo = habitInfo.memo ?? ""
            self.habit = HabitObj.matchingHabitObj(habitInfo.habitType)
            self.isToggle = habitInfo.notificationEnabled
            self.time = Date.convertTimeForIntArray(habitInfo.notificationTime ?? []) ?? .now
            self.method = method
            self.repository = repository
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
            
            do {
                let res = try await repository.create(form: form)
                if res.code == "E40409" {
                    error = .habitLimit
                    return false
                } else if res.code == "E40410" {
                    error = .totalLimit
                    return false
                }
                return true
            } catch {
                debugPrint("습관 기록 작성 실패: \(error.localizedDescription)")
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
            
            do {
                let res = try await repository.update(recordId: recordId, form: form)
                debugPrint("수정 : \(res)")
                return true
            } catch {
                debugPrint("습관 기록 수정 : \(error)")
                return false
            }
        }
        
        func delete() async -> Bool {
            do {
                _ = try await repository.delete(recordId: recordId)
                return true
            } catch {
                debugPrint("기록 삭제 : \(error)")
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

extension HabitRecordView.ViewModel: Hashable, Equatable {
    nonisolated public static func == (lhs: HabitRecordView.ViewModel, rhs: HabitRecordView.ViewModel) -> Bool {
        lhs === rhs
    }
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
