import SwiftUI

enum Page: Identifiable, Hashable, Equatable {
    case root
    case login
    case section
    case finalOnBoarding(message: String?, sm: SectionView.ViewModel)
    case main
    case dailyRecordEdit(dailyInfo: DailyResponse)
    case exerciseRecordEdit(exerciseInfo: ExerciseResponse)
    case habitRecordEdit(habitInfo: HabitResponse)
    case setting(resVM: RecordSelectionView.ViewModel)
    case appNotice(settingVM: SettingView.ViewModel)
    case recordNotice(settingVM: SettingView.ViewModel)
    
    var id: String {
        switch self {
            case .root:
                return "root"
            case .login:
                return "login"
            case .section:
                return "section"
            case .finalOnBoarding:
                return "finalOnBoarding"
            case .main:
                return "main"
            case .setting:
                return "setting"
            case .appNotice:
                return "appNotice"
            case .recordNotice:
                return "recordNotice"
            case .dailyRecordEdit(let dailyInfo):
                return "dailyRecordEdit-\(dailyInfo.base.id)"
            case .exerciseRecordEdit(let exerciseInfo):
                return "exerciseRecordEdit-\(exerciseInfo.base.id)"
            case .habitRecordEdit(let habitInfo):
                return "habitRecordEdit-\(habitInfo.base.id)"
        }
    }
    
    static func == (lhs: Page, rhs: Page) -> Bool {
        switch (lhs, rhs) {
        case (.root, .root), (.login, .login), (.section, .section), (.main, .main):
                return true
            case (.setting(let resVM1), .setting(let resVM2)):
                return resVM1 === resVM2 // ViewModel은 참조 비교
            case (.finalOnBoarding(let msg1, let sm1), .finalOnBoarding(let msg2, let sm2)):
                return msg1 == msg2 && sm1 === sm2 // ViewModel은 참조 비교
            case ((.dailyRecordEdit(let dailyInfo), .dailyRecordEdit(let dailyInfo2))):
                return dailyInfo == dailyInfo2
            case ((.exerciseRecordEdit(let exerciseRes1),.exerciseRecordEdit(let exerciseRes2))):
                return exerciseRes1.base.id == exerciseRes2.base.id
            case ((.habitRecordEdit(let habitRes1), .habitRecordEdit(let habitRes2))):
                return habitRes1.base.id == habitRes2.base.id
            default:
                return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
            case .root:
                hasher.combine("root")
            case .login:
                hasher.combine("login")
            case .section:
                hasher.combine("section")
            case .finalOnBoarding:
                hasher.combine("message")
            case .main:
                hasher.combine("main")
            case .setting(let resVM):
                hasher.combine("setting")
                hasher.combine("setting-\(resVM.user.data?.id ?? "none")")
            case .appNotice(_):
                hasher.combine("appNotice")
            case .recordNotice(_):
                hasher.combine("recordNotice")
            case .dailyRecordEdit(dailyInfo: let dailyInfo):
                hasher.combine("dailyRecordEdit")
                hasher.combine("dailyRecordEdit-\(dailyInfo.base.id)")
            case .exerciseRecordEdit(let exerciseInfo):
                hasher.combine("exerciseRecordEdit")
                hasher.combine("exerciseRecordEdit-\(exerciseInfo.base.id)")
            case .habitRecordEdit(let habitInfo):
                hasher.combine("habitRecordEdit")
                hasher.combine("habitRecordEdit-\(habitInfo.base.id)")
        }
    }
}

enum Sheet: Identifiable {
    case nickName(settingVM: SettingView.ViewModel)
    
    var id: String {
        switch self {
            case .nickName:
                return "nickName"
        }
    }
}

enum FullScreenCover: Equatable, Identifiable, Hashable {
    case recordSelection(selectionVM: RecordSelectionView.ViewModel, selectedDate: Binding<Date?>)
    case dailyRecord(emotion: EmotionObj)
    case exerciseRecord(exercise: ExerciseObj, selectedDate: Binding<Date?>)
    case habitRecord(habit: HabitObj, selectedDate: Binding<Date?>)
    
    var id: String {
        switch self {
            case .recordSelection(_,_):
                return "emotionSelection"
            case .dailyRecord(let emotion):
                return "dailyRecord-\(emotion.rawValue)"
            case .exerciseRecord(let exercise, _):
                return "exerciseRecord-\(exercise.id)"
            case .habitRecord(let habit, _):
                return "habitRecord-\(habit.id)"
        }
    }
    
    static func == (lhs: FullScreenCover, rhs: FullScreenCover) -> Bool {
        switch (lhs, rhs) {
            case (.recordSelection, .recordSelection):
                return true
            case (.dailyRecord(let emotion1), .dailyRecord(let emotion2)):
                return emotion1 == emotion2
            default:
                return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
            case .recordSelection(let selectionVM, _):
                hasher.combine("recordSelection-\(selectionVM.currentRecord.id)")
            case .dailyRecord(let emotion):
                hasher.combine("dailyRecord-\(emotion)")
            case .exerciseRecord(let exercise, _):
                hasher.combine("exerciseRecord-\(exercise.id)")
            case .habitRecord(let habit, _):
                hasher.combine("habitRecord-\(habit.id)")
        }
    }
}

final class Coordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var sheet: Sheet?
    @Published var fullScreenCover: FullScreenCover?
    var sheetVM: MainSheetViewModel = .init(
        useCase: MainSheetUseCase(
            repository: DefaultMainSheetRepository()
        )
    )
    
    @ViewBuilder
    func build(page: Page) -> some View {
        switch page {
            case .root:
                RouterView()
            case .login:
                SocialView()
            case .section:
                SectionView()
            case .finalOnBoarding(let message, let sm):
                FinalOnBoardingView(toastMessage: message)
                    .environmentObject(sm)
            case .main:
                MainView()
                    .environmentObject(sheetVM)
            case .setting(let vm):
                SettingView(resVM: vm)
                    .environmentObject(sheetVM)
            case .dailyRecordEdit(let dailyInfo):
                DayRecordView(dailyInfo: dailyInfo)
                    .environmentObject(sheetVM)
            case .exerciseRecordEdit(let exerciseInfo):
                ExerciseRecordView(exerciseInfo: exerciseInfo)
                    .environmentObject(sheetVM)
            case .habitRecordEdit(let habitInfo):
                HabitRecordView(habitInfo: habitInfo)
                    .environmentObject(sheetVM)
            case .appNotice(let settingVM):
                AppNoticeView()
                    .environmentObject(settingVM)
            case .recordNotice(let settingVM):
                RecordNoticeView()
                    .environmentObject(settingVM)
        }
    }
    
    @ViewBuilder
    func build(sheet: Sheet) -> some View {
        switch sheet {
            case .nickName(let settingVM):
                NickNameChangeView()
                    .environmentObject(settingVM)
                    .environmentObject(sheetVM)
        }
    }
    
    @ViewBuilder
    func build(fullScreenCover: FullScreenCover) -> some View {
        switch fullScreenCover {
            case .recordSelection(let recordVM, let selectedDate):
                RecordSelectionView(selectedDate: selectedDate)
                    .environmentObject(recordVM)
            case .dailyRecord(let emotion):
                DayRecordView(emotion: emotion)
                    .environmentObject(sheetVM)
            case .exerciseRecord(let exercise, let selectedDate):
                ExerciseRecordView(exercise: exercise, selectedDate: selectedDate)
                    .environmentObject(sheetVM)
            case .habitRecord(let habit, let selectedDate):
                HabitRecordView(habit: habit, selectedDate: selectedDate)
                    .environmentObject(sheetVM)
        }
    }
}



// MARK: Page Method
extension Coordinator {
    func push(_ page: Page) {
        path.append(page)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func backInRoot() {
        if path.count > 1 {
            path.removeLast(path.count - 1)
        }
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func getCurrentStack() -> Int {
        path.count
    }
}

// MARK: Sheet Method
extension Coordinator {
    func openSheet(_ sheet: Sheet) {
        self.sheet = sheet
    }
    
    func dismissSheet() {
        self.sheet = nil
    }
}

// MARK: FUll Screen Cover Method
extension Coordinator {
    func present(_ screen: FullScreenCover) {
        self.fullScreenCover = screen
    }
    
    func dismissScreen() {
        self.fullScreenCover = nil
    }
}
