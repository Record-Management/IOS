//
//  SectionOneView.swift
//  RecordManagment
//
//  Created by 김용해 on 8/13/25.
//

import SwiftUI

enum Record {
    case day
    case exercise
    case schedule
}

struct SectionOneView: View {
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
                        subTitle: "습관부터 감정까지, 나의 순간을 기록해요.",
                        record: .day
                    )
                    
                    boxView(
                        title: "운동 기록",
                        subTitle: "운동 루틴과 목표, 오늘의 건강함을 기록해요.",
                        record: .exercise
                    )
                    
                    boxView(
                        title: "일정 기록",
                        subTitle: "해야 할 일과 중요한 순간을 놓치지 말아요.",
                        record: .schedule
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
    }
    
    // TODO: 기록 방식 Box View
    private func boxView(title: String, subTitle: String, record: Record) -> some View {
        let isActive = record == currentRecord
        
        return HStack() {
            Circle()
                .foregroundStyle(Color(hex: "#EEEEEE"))
                .frame(width: 50)
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
                .foregroundStyle(isActive ? Color(hex: "#8A9BA8") : Color(hex: "#E0E0E0"))
        }
        .contentShape(Rectangle())
        .padding(.horizontal)
        .padding(.vertical, 20)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 1)
                .foregroundStyle(isActive ? Color(hex: "#8A9BA8") : Color(hex: "#EEEEEE"))
        }
        .onTapGesture {
            withAnimation {
                self.currentRecord = record
            }
        }
    }
}
