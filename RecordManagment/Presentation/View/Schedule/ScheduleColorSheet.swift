import SwiftUI

struct ScheduleColorSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var color: ScheduleColor
    @Binding var saveState: SaveState
    @State private var oldValue: ScheduleColor = .Orange
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 30), count: 5)
    
    var body: some View {
        NavigationStack {
            List {
                VStack(alignment: .leading, spacing: 16) {
                    Text("색상")
                        .typography(.p16SemiBold)
                        .foregroundStyle(Color.Gray._900())
                    LazyVGrid(columns: columns, spacing: 28) {
                        ForEach(ScheduleColor.allCases, id: \.self) { color in
                            ZStack {
                                Circle()
                                    .fill(colorBackground(color: color))
                                    .frame(width: 40, height: 40)
                                
                                if self.color == color {
                                    Image("Check.White")
                                        .scaledToFit()
                                }
                            }
                            .contentShape(Circle())
                            .onTapGesture {
                                self.color = color
                            }
                        }
                    }
                }
                .padding()
                .listRowInsets(EdgeInsets())
            }
            .scheduleSheetStyle(
                title: "색상 설정",
                backAction: {
                    saveState = .exit(.color(oldValue))
                    dismiss()
                },
                completeAction: {
                    dismiss()
                }
            )
            .onAppear {
                oldValue = color
                saveState = .none
            }
        }
    }
}

// MARK: - Helper

extension ScheduleColorSheet {
    private func colorBackground(color: ScheduleColor) -> Color {
        switch color {
        case .Red:    return Color(hex: "#FF5B52")
        case .Orange: return Color(hex: "#FF9528")
        case .Yellow: return Color(hex: "#FFCC00")
        case .Green:  return Color(hex: "#34C759")
        case .Blue:   return Color(hex: "#007AFF")
        case .Indigo:   return Color(hex: "#004080")
        case .Pink:   return Color(hex: "#FF2D55")
        case .Gray:   return Color.Gray._400()
        }
    }
}
