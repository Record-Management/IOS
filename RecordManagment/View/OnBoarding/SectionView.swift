//
//  SectionView.swift
//  RecordManagment
//
//  Created by 김용해 on 8/14/25.
//

import SwiftUI

struct SectionView: View {
    @EnvironmentObject var coordinator: Coordinator
    @State private var currentProgress: ProgressPage = .record
    @State private var currentRecord: Record = .day
    @State private var name: String = ""
    @State private var selectGoal: SectionFourView.GoalTypes = .first
    var body: some View {
        VStack {
            ProgressView(value: currentProgress.rawValue + 1.0, total: ProgressPage.totalPage)
                .progressViewStyle(.linear)
            
            switch currentProgress {
                case .record:
                    SectionOneView(currentRecord: $currentRecord)
                case .name:
                    SectionTwoView(name: $name)
                case .birth:
                    SectionThreeView()
                case .goal:
                    SectionFourView(selectedGoal: $selectGoal)
            }
            
            Button(action: {
                next(currentProgress) {
                    // 모든 Progress 를 빠져나갑니다
                    coordinator.push(.finalOnBoarding)
                }
            }, label: {
                Text("다음")
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            })
        }
        .padding()
    }
}

extension SectionView {
    
    /// ** Page 진행도를 위한 data 구조
    /// - enum: 각 Double값을 줌으로서 순차적인 진행 Page적용
    /// - next: 다음 페이지 이동
    /// - pop: 전 페이지 읻
    enum ProgressPage: Double, CaseIterable {
        case record
        case name
        case birth
        case goal
        
        static var totalPage: Double {
            Double(allCases.count)
        }
    }
    
    func next(_ current: ProgressPage, completion: (() -> Void)?) {
        if current == ProgressPage.allCases.last {
            completion?()
        }else {
            withAnimation {
                currentProgress = ProgressPage.allCases[Int(current.rawValue + 1.0)]
            }
        }
    }
}

#Preview {
    SectionView()
}
