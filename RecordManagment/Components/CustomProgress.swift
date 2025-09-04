//
//  CustomProgress.swift
//  RecordManagment
//
//  Created by 김용해 on 9/1/25.
//

import SwiftUI

struct CustomProgress: View {
    let value: Double
    let total: Double
    var body: some View {
        ProgressView(value: value, total: total)
            .progressViewStyle(SeedayCustomProgressStyle())
    }
}


struct SeedayCustomProgressStyle: ProgressViewStyle {
    var trackColor: Color = Color(hex: "#FFF0E1")
    var progressColor: Color = Color(hex: "#FF9528")
    
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(trackColor)
                    .frame(maxHeight: 4)
                Capsule()
                    .fill(progressColor)
                    .frame(maxWidth: geo.size.width * CGFloat(configuration.fractionCompleted ?? 0), maxHeight: 4)
            }
        }
        .frame(maxHeight: 4)
    }
}

#Preview {
    CustomProgress(value: 0.5, total: 1.0)
}
