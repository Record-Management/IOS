//
//  ExerciseRecordView.swift
//  RecordManagment
//
//  Created by 김용해 on 10/1/25.
//

import SwiftUI

struct ExerciseRecordView: View {
    let exercise: ExerciseObj
    @State private var isDismiss: Bool = false
    @State private var kcal: String = ""
    @State private var time: String = ""
    @State private var step: String = ""
    @State private var weight: String = ""
    @State private var text: String = ""
    @FocusState var isFocused: Bool
    
    init(exercise: ExerciseObj) {
        self.exercise = exercise
        clearBackground()
    }
    
    var body: some View {
        NavigationStack {
            content
        }
    }
    
    private var content: some View {
        VStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(exercise.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 100, maxHeight: 100)
                    Text(exercise.getName())
                        .typography(.p16SemiBold)
                    inputGroup(title: "소모 칼로리", placeHolder: "0 kcal", text: $kcal)
                    inputGroup(title: "운동 시간", placeHolder: "0 분", text: $time)
                    inputGroup(title: "걸음 수", placeHolder: "0 걸음", text: $step)
                    inputGroup(title: "몸무게", placeHolder: "0 kg", text: $weight)
                    inputGroup(title: "나의 하루", placeHolder: "NAN", text: $text, isMultiField: true)
                }
            }
            .scrollIndicators(.hidden)
            RecordButton(isEditing: .constant(false), text: $text) {
                
            }
        }
        .padding(.horizontal)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationTitle("운동 기록")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image("xmark")
                    .frame(maxWidth: 24, maxHeight: 24)
                    .higFullScreenBackSize()
                    .onTapGesture {
                        withAnimation(.interactiveSpring) {
                            isDismiss = true
                        }
                    }
            }
        }
        .overlay {
            if isDismiss {
                DismissAlertView(isDismiss: $isDismiss, isEditing: .constant(false))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = false
        }
    }
    
    // TODO: TextLabel Group 뷰
    func inputGroup(title: String, placeHolder: String, text: Binding<String>, isMultiField: Bool = false) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .typography(.p14SemiBold)
                .frame(maxWidth: .infinity, alignment: .leading)
            if isMultiField {
                MultiTextField(text: $text, isFocused: $isFocused)
            } else {
                TextField(placeHolder, text: text)
                    .padding(14)
                    .background(Color.Gray._100())
                    .clipShape(.rect(cornerRadius: 8))
            }
        }
    }
}

#Preview {
    ExerciseRecordView(exercise: .baseball)
}
