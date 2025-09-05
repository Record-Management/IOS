//
//  SectionOneView.swift
//  RecordManagment
//
//  Created by 김용해 on 8/13/25.
//

import SwiftUI

enum Record: String {
    case none
    case day
    case exercise
    case schedule
    case habit
    
    // TODO: 온보딩 Request Body값 변환을 위한 함수
    func localizedString() -> String {
        switch self {
        case .day:
            return "DAILY"
        case .exercise:
            return "EXERCISE"
        case .habit:
            return "HABIT"
        case .schedule:
            return ""
        default:
            return ""
        }
    }
}

struct SectionOneView: View {
    @EnvironmentObject var coordinator: Coordinator
    @Binding var currentRecord: Record
    
    var body: some View {
        VStack(alignment: .leading) {
            Image("Workout")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 30, maxHeight: 30)
                .padding(.vertical, 10)
            Text("꾸준함, 어렵지 않아요 :)\n내게 맞는 기록 방식을 골라보세요.")
                .font(.system(size: 22, weight: .bold))
                .padding(.vertical, 10)
                .lineSpacing(11)
            Spacer()
            
            VStack {
                Group {
                    boxView(
                        title: "하루 기록",
                        subTitle: "나의 찰나와 감정까지, 오늘을 기록해요",
                        record: .day,
                        iconColor: Color(hex: "#EDF8FF"),
                        iconSize: CGSize(width: 48, height: 48)
                    )
                    
                    boxView(
                        title: "운동 기록",
                        subTitle: "운동 루틴과 목표, 오늘의 건강함을 기록해요.",
                        record: .exercise,
                        iconColor: Color(hex: "#EAF1F8"),
                        iconSize: CGSize(width: 43, height: 24)
                    )
                    
                    boxView(
                        title: "일정 기록",
                        subTitle: "해야 할 일과 중요한 순간을 놓치지 말아요.",
                        record: .schedule,
                        iconColor: Color(hex: "#FFF5EB"),
                        iconSize: CGSize(width: 28, height: 30)
                    )
                    
                    boxView(
                        title: "습관 기록",
                        subTitle: "작은 습관부터, 나의 변화를 기록해요.",
                        record: .habit,
                        iconColor: Color(hex: "#EEF8F0"),
                        iconSize: CGSize(width: 23, height: 34)
                    )
                }
                .padding(.bottom, 9)
                Spacer()
            }
            .frame(maxHeight: .infinity)
            .padding(.top, 58)
            
            Spacer()
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    coordinator.pop()
                }) {
                    Image(systemName: "chevron.left")
                }
                .opacity(coordinator.getCurrentStack() > 1 ? 1 : 0)
            }
        }
    }
    
    // TODO: 기록 방식 Box View
    private func boxView(title: String, subTitle: String, record: Record, iconColor: Color, iconSize: CGSize) -> some View {
        let isActive = record == currentRecord
        
        return HStack() {
            Circle()
                .foregroundStyle(iconColor)
                .frame(maxWidth: 50, maxHeight: 50)
                .overlay {
                    Image(record.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: iconSize.width, maxHeight: iconSize.height)
                }
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(subTitle)
                    .font(.caption)
                    .foregroundStyle(Color(hex: "#616161"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: isActive ? "checkmark.circle.fill" : "checkmark.circle")
                .frame(maxWidth: 20)
                .foregroundStyle(isActive ? Color(hex: "#FF9528") : Color(hex: "#F5F5F5"))
        }
        .contentShape(Rectangle())
        .padding(.horizontal)
        .padding(.vertical, 20)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 1)
                .foregroundStyle(isActive ? Color(hex: "#FF9528") : Color(hex: "#F5F5F5"))
        }
        .onTapGesture {
            withAnimation(.interactiveSpring) {
                self.currentRecord = record
            }
        }
    }
}
