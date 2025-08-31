//
//  Coordinator.swift
//  RecordManagment
//
//  Created by 김용해 on 8/13/25.
//

import SwiftUI

enum Page: String,Identifiable, Hashable {
    case login
    case section
    case finalOnBoarding
    
    
    var id: String {
        self.rawValue
    }
}

enum Sheet: String,Identifiable, Hashable {
    case test
    
    var id: String {
        self.rawValue
    }
}

enum FullScreenCover: String, Identifiable, Hashable {
    case test
    
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
            case .login:
                SocialView()
            case .section:
                SectionView()
            case .finalOnBoarding:
                FinalOnBoardingView()
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
            case .test:
                EmptyView()
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
}
