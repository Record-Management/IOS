//
//  EmotionSelectionView .swift
//  RecordManagment
//
//  Created by 김용해 on 9/12/25.
//

import SwiftUI

struct EmotionSelectionView: View {
    @EnvironmentObject var coordinator: Coordinator
    @State private var isAlert: Bool = false
    @State private var currentRecord: Record = .daily
    @State private var selectedRecord: Record = .none
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("오늘의 감정을 선택해 주세요")
                    .typography(.p20SemiBold)
                EmotionView(isFullScreen: true)
                Spacer()
                Text("기록 방식을 바꿀래요")
                    .typography(.p14Medium)
                    .underline()
                    .foregroundStyle(Color.Gray._600())
                    .onTapGesture {
                        self.isAlert = true
                    }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image("xmark")
                        .frame(maxWidth: 24, maxHeight: 24)
                        .higFullScreenBackSize()
                        .onTapGesture {
                            coordinator.dismissScreen()
                        }
                }
            }
            .overlay {
                if isAlert {
                    ChangeRecordAlertView(
                        isAlert: $isAlert,
                        currentRecord: $currentRecord,
                        selectedRecord: $selectedRecord
                    )
                }
            }
        }
    }
}

#Preview {
    EmotionSelectionView()
}
