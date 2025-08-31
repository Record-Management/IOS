//
//  SectionThreeView.swift
//  RecordManagment
//
//  Created by 김용해 on 8/13/25.
//

import SwiftUI

struct SectionFourView: View {
    @Binding var selectedGoal: GoalTypes
    var body: some View {
        VStack(alignment: .leading) {
            Image("Goal")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 30, maxHeight: 30)
                .padding(.vertical, 10)
            Text("목표를 정해볼까요?\n작은 목표가 큰 변화를 만들어요.")
                .font(.system(size: 22, weight: .bold))
                .padding(.vertical, 10)
                .lineSpacing(11)
            Spacer()

            VStack(alignment: .leading) {
                HStack {
                    ForEach(goals, id: \.type) { goal in
                        goalBox(of: goal)
                    }
                }
                .frame(maxWidth: .infinity)
                Spacer()
            }
            .frame(maxHeight: .infinity)
            .padding(.top, 58)
            
            Spacer()
            Spacer()
        }
    }
    
    private func goalBox(of goal: Goal) -> some View {
        let isActive = selectedGoal == goal.type
        return VStack {
            Group {
                Circle()
                    .foregroundStyle(Color(hex: "#EEEEEE"))
                    .frame(width: 56)
                Spacer().frame(height: 14)
                Text(goal.title)
                    .font(.caption)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
                    .background(Color(hex: "#F5F5F5"))
                    .clipShape(.rect(cornerRadius: 6))
                Spacer().frame(height: 6)
                Text("\(goal.day)일")
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .onTapGesture {
            withAnimation {
                self.selectedGoal = goal.type
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isActive ? Color(hex: "#8A9BA8") : Color(hex: "#EEEEEE"), lineWidth: 1)
        }
    }
}

// MARK: Data Modelring
extension SectionFourView {
    enum GoalTypes: String, Identifiable {
        case first
        case second
        case third
        
        var id: String {
            self.rawValue
        }
    }
    
    struct Goal {
        let title: String
        let day: Int
        let type: GoalTypes
    }
}


// MARK: Data 변수 정의
extension SectionFourView {
    var goals: [Goal] {
        [
            Goal(title: "첫 걸음", day: 10, type: .first),
            Goal(title: "첫 걸음", day: 20, type: .second),
            Goal(title: "꾸준한 성장", day: 30, type: .third)
        ]
    }
}

#Preview {
    SectionFourView(selectedGoal: .constant(.first))
        .padding()
}
