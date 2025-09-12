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
        }
    }
    
    static func == (lhs: Page, rhs: Page) -> Bool {
        switch (lhs, rhs) {
            case (.root, .root), (.login, .login), (.section, .section), (.main, .main):
                return true
            case (.finalOnBoarding(let msg1, let sm1), .finalOnBoarding(let msg2, let sm2)):
                return msg1 == msg2 && sm1 === sm2 // ViewModel은 참조 비교
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
        }
    }
}

enum Sheet: String,Identifiable, Hashable {
    case test
    
    var id: String {
        self.rawValue
    }
}

enum FullScreenCover: String, Identifiable, Hashable {
    case emotionSelection
    
    var id: String {
        self.rawValue
    }
}

final class Coordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var sheet: Sheet?
    @Published var fullScreenCover: FullScreenCover?
    
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
            case .emotionSelection:
                EmotionSelectionView()
        }
    }
}



// MARK: Page Method
extension Coordinator {
    func push(_ page: Page) {
        path.append(page)
    }
    
    func pop() {
        path.removeLast()
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
