import SwiftUI

struct ExerciseListView: View {
    @EnvironmentObject var coordinator: Coordinator
    let title: String
    let action: ((ExerciseObj) -> Void)?
    init(title: String = "운동 선택" ,action: ((ExerciseObj) -> Void)? = nil) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(ExerciseObj.allCases, id: \.id) { exercise in
                    HStack {
                        Image(exercise.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 50, maxHeight: 50)
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                    }
                    .exerciseListStyle(name: exercise.getName())
                    .onTapGesture {
                        action?(exercise)
                    }
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
        .navigationTitle(self.title)
    }
}
