//
//  FloatingButton.swift
//  RecordManagment
//
//  Created by 김용해 on 9/12/25.
//

import SwiftUI

struct FloatingButton: View {
    let handler: () -> Void
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.Primary.main())
                .frame(width: 52, height: 52)
            Image(systemName: "pencil")
                .foregroundStyle(.white)
        }
        .onTapGesture {
            handler()
        }
    }
}
