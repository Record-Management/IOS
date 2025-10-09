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
                        Text(exercise.getName())
                            .typography(.p16SemiBold)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .frame(maxWidth: .infinity, maxHeight: 70)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.Gray._50())
                    .clipShape(.rect(cornerRadius: 8))
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

#Preview {
    NavigationStack {
        ExerciseListView()
            .navigationBarTitleDisplayMode(.inline)
    }
}
