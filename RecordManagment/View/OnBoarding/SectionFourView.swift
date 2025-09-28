//
//  SectionThreeView.swift
//  RecordManagment
//
//  Created by 김용해 on 8/13/25.
//

import SwiftUI

struct SectionFourView: View {
    @Binding var selectedGoal: GoalTypes
    @Binding var currentProgress: SectionView.ProgressPage
    var body: some View {
        VStack(alignment: .leading) {
            Image("Goal")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 30, maxHeight: 30)
                .padding(.vertical, 10)
            Text("목표를 정해볼까요?\n작은 목표가 큰 변화를 만들어요.")
                .typography(.p22Bold)
                
            Spacer()

            VStack(alignment: .leading) {
                HStack {
                    ForEach(goals, id: \.type) { goal in
                        goalBox(of: goal)
                        if goal.type != goals.last!.type {
                            Spacer()
                        }
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
        .navigationBarBackButtonHidden(currentProgress == .goal)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                  Button(action: {
                      // prev 상태로 이동
                      withAnimation {
                          currentProgress = .birth
                      }
                  }) {
                      Image(systemName: "chevron.left")
                          .higBackSize()
                          .foregroundStyle(Color.Gray._900())
                  }
            }
        }
    }
    
    private func goalBox(of goal: Goal) -> some View {
        let isActive = selectedGoal == goal.type
        return VStack {
            Circle()
                .foregroundStyle(goal.type.getBgColor())
                .frame(width: 56)
                .overlay {
                    Image(goal.type.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: goal.size.width, maxHeight: goal.size.height)
                        .offset(x: goal.type == .third ? 2 : 0)
                }
            Spacer().frame(height: 14)
            Text(goal.title)
                .typography(.p12Medium)
                .padding(.vertical, 2)
                .padding(.horizontal, 6)
                .background(goal.type.getBgColor())
                .foregroundStyle(goal.type.getTextColor())
                .clipShape(.rect(cornerRadius: 6))
            Spacer().frame(height: 6)
            Text("\(goal.day)일")
                .typography(.p18SemiBold)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                self.selectedGoal = goal.type
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isActive ? Color.Primary.main() : Color(hex: "#EEEEEE"), lineWidth: 1)
                .shadow(color: isActive ? .black.opacity(0.1) : .clear, radius: isActive ? 4 : 0, x: 0, y: 2)
        }
    }
}

// MARK: Data Modelring
extension SectionFourView {
    enum GoalTypes: String, Identifiable {
        case none
        case first
        case second
        case third
        
        var id: String {
            self.rawValue
        }
        
        func getBgColor() -> Color {
            switch self {
                case .first:
                    Color(hex: "#FDF7DF")
                case .second:
                    Color(hex: "#FDEDDC")
                case .third:
                    Color(hex: "#72C83A").opacity(0.24)
                default:
                    .gray
            }
        }
        
        func getTextColor() -> Color {
            switch self {
                case .first:
                    Color(hex: "#FFA30F")
                case .second:
                    Color(hex: "#E65100")
                case .third:
                    Color(hex: "#1B5E20")
                default:
                    .gray
            }
        }
        
        // TODO: localizedInt for Request Body
        func localizedInt() -> Int {
            switch self {
                case .first:
                    10
                case .second:
                    20
                case .third:
                    30
                default:
                    0
            }
        }
    }
    
    struct Goal {
        let title: String
        let day: Int
        let type: GoalTypes
        let size: CGSize
    }
}


// MARK: Data 변수 정의
extension SectionFourView {
    var goals: [Goal] {
        [
            Goal(title: "첫 걸음", day: 10, type: .first, size: CGSize(width: 24, height: 24)),
            Goal(title: "습관의 시작", day: 20, type: .second, size: CGSize(width: 18, height: 43)),
            Goal(title: "꾸준한 성장", day: 30, type: .third, size: CGSize(width: 37, height: 42))
        ]
    }
}

#Preview {
    SectionFourView(selectedGoal: .constant(.first), currentProgress: .constant(.goal))
        .padding()
}
