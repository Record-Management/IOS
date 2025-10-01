import SwiftUI

struct ExerciseListView: View {
    @EnvironmentObject var coordinator: Coordinator
    
    init() {
        clearBackground()
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
                        coordinator.present(.exerciseRecord(exercise: exercise))
                    }
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("운동 기록")
    }
}

#Preview {
    NavigationStack {
        ExerciseListView()
            .navigationBarTitleDisplayMode(.inline)
    }
}
