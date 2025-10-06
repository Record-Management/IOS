//
//  Coordinator.swift
//  RecordManagment
//
//  Created by 김용해 on 8/13/25.
//

import SwiftUI

enum Page: Identifiable, Hashable, Equatable {
    case root
    case login
    case section
    case finalOnBoarding(message: String?, sm: SectionView.ViewModel)
    case main
    case dailyRecordEdit(dailyInfo: DailyResponse)
    case exerciseRecordEdit(exerciseInfo: ExerciseResponse)
    
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
            case .dailyRecordEdit(let dailyInfo):
                return "dailyRecordEdit-\(dailyInfo.base.id)"
            case .exerciseRecordEdit(let exerciseInfo):
                return "exerciseRecordEdit-\(exerciseInfo.base.id)"
        }
    }
    
    static func == (lhs: Page, rhs: Page) -> Bool {
        switch (lhs, rhs) {
        case (.root, .root), (.login, .login), (.section, .section), (.main, .main):
                return true
            case (.finalOnBoarding(let msg1, let sm1), .finalOnBoarding(let msg2, let sm2)):
                return msg1 == msg2 && sm1 === sm2 // ViewModel은 참조 비교
            case ((.dailyRecordEdit(let dailyInfo), .dailyRecordEdit(let dailyInfo2))):
                return dailyInfo == dailyInfo2
            case ((.exerciseRecordEdit(let exerciseRes1),.exerciseRecordEdit(let exerciseRes2))):
                return exerciseRes1.base.id == exerciseRes2.base.id
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
            case .dailyRecordEdit(dailyInfo: let dailyInfo):
                hasher.combine("dailyRecordEdit")
                hasher.combine("dailyRecordEdit-\(dailyInfo.base.id)")
            case .exerciseRecordEdit(let exerciseInfo):
                hasher.combine("exerciseRecordEdit")
                hasher.combine("exerciseRecordEdit-\(exerciseInfo.base.id)")
        }
    }
}

enum Sheet: String,Identifiable, Hashable {
    case test
    
    var id: String {
        self.rawValue
    }
}

enum FullScreenCover: Equatable, Identifiable, Hashable {
    case recordSelection
    case dailyRecord(emotion: EmotionObj)
    case exerciseRecord(exercise: ExerciseObj)
    
    var id: String {
        switch self {
            case .recordSelection:
                return "emotionSelection"
            case .dailyRecord(let emotion):
                return "dailyRecord-\(emotion.rawValue)"
            case .exerciseRecord(let exercise):
                return "exerciseRecord-\(exercise.id)"
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
            case .recordSelection:
                hasher.combine("recordSelection")
            case .dailyRecord(let emotion):
                hasher.combine("dailyRecord-\(emotion)")
            case .exerciseRecord(let exercise):
                hasher.combine("exerciseRecord-\(exercise.id)")
        }
    }
}

final class Coordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var sheet: Sheet?
    @Published var fullScreenCover: FullScreenCover?
    var sheetVM: MainSheetViewModel = .init()
    
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
            case .dailyRecordEdit(let dailyInfo):
                DayRecordView(dailyInfo: dailyInfo)
                    .environmentObject(sheetVM)
            case .exerciseRecordEdit(let exerciseInfo):
                ExerciseRecordView(exerciseInfo: exerciseInfo)
                    .environmentObject(sheetVM)
        }
    }
    
    @ViewBuilder
    func build(sheet: Sheet) -> some View {
        switch sheet {
            case .test:
                EmptyView()
        }
    }
    
    @ViewBuilder
    func build(fullScreenCover: FullScreenCover) -> some View {
        switch fullScreenCover {
            case .recordSelection:
                RecordSelectionView()
            case .dailyRecord(let emotion):
                DayRecordView(emotion: emotion)
                    .environmentObject(sheetVM)
            case .exerciseRecord(let exercise):
                ExerciseRecordView(exercise: exercise)
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
