import SwiftUI

struct HabitListView: View {
    let title: String
    let action: ((HabitObj) -> Void)?
    
    init(title: String = "습관 선택", action: ((HabitObj) -> Void)?) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(HabitObj.allCases, id: \.id) { habit in
                    HStack {
                        Image(habit.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 50, maxHeight: 50)
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                    }
                    .habitListStyle(name: habit.getName())
                    .onTapGesture {
                        action?(habit)
                    }
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
        .navigationTitle(self.title)
    }
}

#Preview {
    NavigationStack {
        HabitListView(
            title: "습관 선택", action: { _ in }
        )
    }
}
