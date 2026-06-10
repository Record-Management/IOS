//
//  EmotionView.swift
//  RecordManagment
//
//  Created by 김용해 on 9/13/25.
//

import SwiftUI

struct EmotionView: View {
    @EnvironmentObject var coordinator: Coordinator
    let completion: ((EmotionObj) -> Void)?
    let columes: [GridItem] = Array(repeating: GridItem(.flexible()), count: 3)
    let isFullScreen: Bool
    init(isFullScreen: Bool ,completion: ((EmotionObj) -> Void)? = nil) {
        self.isFullScreen = isFullScreen
        self.completion = completion
    }
    
    var body: some View {
        LazyVGrid(columns: columes, spacing: 24) {
            ForEach(EmotionObj.allCases, id: \.rawValue) { emotion in
                Image(emotion.id)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 80, maxHeight: 80)
                    .onTapGesture {
                        if isFullScreen {
                            coordinator.dismissScreen()
                            let vm = coordinator.appContainer.makeDayRecordViewModel(emotion: emotion)
                            coordinator.present(.dailyRecord(vm: vm))
                        }else {
                            completion?(emotion)
                        }
                    }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 40)
    }
}
//
//#Preview {
//    EmotionView()
//}
