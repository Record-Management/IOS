//
//  EmotionView.swift
//  RecordManagment
//
//  Created by 김용해 on 9/13/25.
//

import SwiftUI

struct EmotionView: View {
    @EnvironmentObject var coordinator: Coordinator
    let columes: [GridItem] = Array(repeating: GridItem(.flexible()), count: 3)
    var body: some View {
        LazyVGrid(columns: columes, spacing: 24) {
            ForEach(EmotionObj.allCases, id: \.rawValue) { emotion in
                Image(emotion.id)
                    .resizable()
                    .scaledToFit()
                    .onTapGesture {
                        coordinator.dismissScreen()
                        coordinator.present(.dailyRecord(emotion: emotion))
                    }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 40)
    }
}

#Preview {
    EmotionView()
}
