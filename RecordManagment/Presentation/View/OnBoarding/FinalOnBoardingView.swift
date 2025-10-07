//
//  SectionLastView.swift
//  RecordManagment
//
//  Created by 김용해 on 8/15/25.
//

import SwiftUI

struct FinalOnBoardingView: View {
    @EnvironmentObject var sm: SectionView.ViewModel
    @EnvironmentObject var coordinator: Coordinator
    @State private var totalBarHeight: CGFloat = 0
    @State private var visibleBoxes: [Bool] = []
    @State private var visibleToast: Bool = true
    var toastMessage: String?

    init(toastMessage: String?) {
        self.toastMessage = toastMessage
    }
    
    var body: some View {
        VStack {
            Image("Final_On_Boarding")
                .resizable()
                .scaledToFit()
                .background(
                    NavigationBarProxy { _ , navBar, _ in
                        self.totalBarHeight = navBar.bounds.height
                    }
                )
                .padding(.horizontal ,48)
                .padding(.bottom, 28)
                .padding(.top, totalBarHeight)
            
            Text("하루를 채울 준비를 마쳤어요!")
                .typography(.p22Bold)
                .fontWeight(.bold)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 14) {
                if visibleBoxes.indices.contains(0) {
                    infoBox(title: "당신에게 맞는 기록을 준비하고 있어요.")
                        .offset(y: visibleBoxes[0] ? 0 : 10)
                        .opacity(visibleBoxes[0] ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5), value: visibleBoxes[0])
                }
                if visibleBoxes.indices.contains(1) {
                    infoBox(title: "목표를 살펴보고 있어요.")
                        .offset(y: visibleBoxes[1] ? 0 : 10)
                        .opacity(visibleBoxes[1] ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5), value: visibleBoxes[1])
                }
                if visibleBoxes.indices.contains(2) {
                    infoBox(title: "이제 시작할 수 있어요!")
                        .offset(y: visibleBoxes[2] ? 0 : 10)
                        .opacity(visibleBoxes[2] ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5), value: visibleBoxes[2])
                }
            }
            Spacer()
            Spacer()
            if visibleBoxes.indices.contains(3) {
                Button(action: {
                    Task {
                        switch await sm.completeOnBoarding() {
                            case .main:
                                coordinator.push(.main)
                            case .register:
                                coordinator.backInRoot()
                            default:
                                coordinator.popToRoot()
                        }
                    }
                }, label: {
                    Text("시작하기")
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(Color.Primary.main())
                        .foregroundColor(.white)
                        .cornerRadius(8)
                })
                .opacity(visibleBoxes[3] ? 1 : 0)
                .animation(.easeInOut(duration: 1.4), value: visibleBoxes[3])
            }
        }
        .navigationBarBackButtonHidden()
        .padding()
        .overlay {
            ToastMessage(
                visibleToast: $visibleToast,
                toastMessage: toastMessage
            )
        }
        .onAppear {
            // Initialize all boxes as not visible
            visibleBoxes = [false, false, false, false]
            
            for i in 0..<visibleBoxes.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.7) {
                    if visibleBoxes.indices.contains(i) {
                        visibleBoxes[i] = true
                    }
                }
            }
            
            guard toastMessage != nil else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                withAnimation {
                    self.visibleToast = false
                }
            }
        }
    }
    
    // TODO: Guide Label
    private func infoBox(title: String) -> some View {
        HStack(spacing: 0) {
            Image(systemName: "checkmark.circle.fill")
                .frame(width: 20)
                .foregroundStyle(Color.Primary.main())
                .padding(.trailing, 14)
            Text(title)
                .typography(.p14Medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                
        }
        .padding(.vertical, 13)
        .padding(.horizontal)
        .background(Color.Gray._100())
        .clipShape(.rect(cornerRadius: 8))
    }
}

#Preview {
    FinalOnBoardingView(toastMessage: "Test용입니다")
        .environmentObject(SectionView.ViewModel())
        .environmentObject(RouterView.ViewModel())
}
