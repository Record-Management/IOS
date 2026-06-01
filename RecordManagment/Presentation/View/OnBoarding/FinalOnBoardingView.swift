import SwiftUI

struct FinalOnBoardingView: View {
    @ObservedObject var vm: SectionView.ViewModel
    @EnvironmentObject var coordinator: Coordinator
    @State private var totalBarHeight: CGFloat = 0
    @State private var visibleBoxes: [Bool] = []
    @State private var visibleToast: Bool = true
    @State private var animationTask: Task<Void, Never>? = nil
    @State private var toastTask: Task<Void, Never>? = nil
    var toastMessage: String?

    init(vm: SectionView.ViewModel, toastMessage: String?) {
        self.vm = vm
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
                Button("시작하기") {
                    Task {
                        if vm.firstOnBoarding {
                            switch await vm.completeOnBoarding() {
                                case .main:
                                    coordinator.path.removeAll()
                                    await coordinator.routeToMainWithPreload()
                                case .register:
                                    coordinator.backInRoot()
                                default:
                                    coordinator.popToRoot()
                            }
                        } else { // 목표 재설정일 경우
                            let result: Bool = await vm.onBoardingReSelection()
                            if result {
                                coordinator.push(.root)
                            }
                        }
                    }
                }
                .seedDaysButtonStyle(type: .success, state: .primary)
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
        .onDisappear {
            animationTask?.cancel()
            toastTask?.cancel()
            BackSwipeManager.shared.updatePopGesture(false)
        }
        .onAppear {
            visibleBoxes = [false, false, false, false]
            
            animationTask = Task {
                for i in 0..<4 {
                    if Task.isCancelled { return }
                    if i > 0 {
                        do {
                            try await Task.sleep(nanoseconds: 700_000_000)
                        } catch {
                            return
                        }
                    }
                    if Task.isCancelled { return }
                    if visibleBoxes.indices.contains(i) {
                        visibleBoxes[i] = true
                    }
                }
            }
            
            guard toastMessage != nil else { return }
            toastTask = Task {
                do {
                    try await Task.sleep(nanoseconds: 2_100_000_000)
                } catch {
                    return
                }
                if Task.isCancelled { return }
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
