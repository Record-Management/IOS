import SwiftUI

struct HabitMainRecordStyle: ViewModifier {
    let isMainRecord: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottomTrailing){
                if isMainRecord {
                    ZStack {
                        Circle().fill(Color.Primary.lighter())
                        Image("Pin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                    }
                    .frame(width: 16, height: 16)
                }
            }
    }
}

extension View {
    func habitMainPin(isMainRecord : Bool) -> some View {
        self
            .modifier(HabitMainRecordStyle(isMainRecord: isMainRecord))
    }
}
