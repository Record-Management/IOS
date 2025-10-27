//
//  RecordListTile.swift
//  RecordManagment
//
//  Created by 김용해 on 10/22/25.
//

import SwiftUI


struct RecordListTile: View {
    let title: String
    let subline: String?
    @Binding var isOn: Bool
    @Binding var systemIsOn: Bool
    
    init(title: String, subline: String? = nil, isOn: Binding<Bool>, systemIsOn: Binding<Bool> = .constant(false)) {
        self.title = title
        self.subline = subline
        self._isOn = isOn
        self._systemIsOn = systemIsOn
    }
    
    var body: some View {
        VStack(alignment: .leading ,spacing: 4) {
            HStack {
                Text(title)
                    .typography(.p16SemiBold)
                Toggle("", isOn: $isOn)
                    .disabled(!systemIsOn)
            }
            if let subline = subline {
                Text(subline)
                    .typography(.p14Medium)
                    .foregroundStyle(Color.Gray._500())
            }
        }
    }
}
