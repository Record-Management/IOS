//
//  EmotionSelectionView .swift
//  RecordManagment
//
//  Created by 김용해 on 9/12/25.
//

import SwiftUI

struct EmotionSelectionView: View {
    @EnvironmentObject var coordinator: Coordinator
    var body: some View {
        NavigationStack {
            VStack {
                Text("FullScreen Cover")
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "xmark")
                        .onTapGesture {
                            coordinator.dismissScreen()
                        }
                }
            }
        }
    }
}
