import SwiftUI

// MARK: - Draggable Panel View
struct MainSheet: View {
    var offset: CGFloat
    var topDetent: CGFloat
    @State private var scrollOffset: CGFloat = 0
    @Binding var sheetState: SheetState
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var rm: RouterView.ViewModel
    @EnvironmentObject private var vm: MainSheetViewModel
    @StateObject var calendarVM: CalendarView.ViewModel = .init()
    @StateObject private var recordService = RecordService.shared
    var loginManager: LoginNetworkManager = .init()
    
    init(offset: CGFloat, topDetent: CGFloat, sheetState: Binding<SheetState>) {
        self.offset = offset
        self.topDetent = topDetent
        self._sheetState = sheetState
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.secondary)
                .frame(width: 40, height: 5)
                .padding(.vertical, 10)

            ScrollView {
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: 0)
                        .readingScrollOffset { minY in
                            // minY는 스크롤 다운 시 음수로 내려가므로, 양수 오프셋으로 변환
                            scrollOffset = -minY
                        }
                    CalendarView(vm: calendarVM)
                        .environmentObject(vm)
                        .padding(.top, 9)
                    Group {
                        Divider()
                        if let currentDate = recordService.selectedDate, !recordService.detailRecords.isEmpty {
                            Text(Date.dailyRecordDateFormat(currentDate))
                                .typography(.p18SemiBold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 24)
                        }
                        VStack {
                            ForEach(recordService.detailRecords, id: \.self) { record in
                                switch record {
                                case .daily(let dailyInfo):
                                    DailyView(dailyInfo: dailyInfo)
                                case .exercise(let exerciseInfo):
                                    EmptyView()
                                }
                            }
                        }
                        .onChange(of: vm.visibleToast) {
                            if vm.visibleToast {
                                recordService.refreshSubject.send()
                            }
                        }
                    }
                    .padding(.horizontal)
                    testBox()
                }
                .padding(.bottom, (sheetState == .medium ? offset : topDetent) + 80)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color(.systemBackground))
        .frame(height: UIScreen.main.bounds.height)
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .offset(y: sheetState == .medium ? offset : topDetent)
        .animation(.spring(duration: 0.25), value: sheetState)
        .simultaneousGesture(
            DragGesture()
                .onEnded { value in
                    let move = value.translation.height
                    
                    guard scrollOffset <= 0 else { return }
                    
                    if move > 100 {
                        SheetState.down(&sheetState)
                    } else if move < -100 {
                        SheetState.up(&sheetState)
                    }
                }
        )
        .overlay {
            ToastMessage(visibleToast: $vm.visibleToast, toastMessage: vm.toastMessage)
        }
    }
    
    // TODO: 로그아웃, 회원탈퇴 Test Box
    private func testBox() -> some View {
        Group {
            Button("logout") {
                Task {
                    await loginManager.logout()
                    await MainActor.run {
                        rm.currentState = .login
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            Button("회원 탈퇴") {
                Task {
                    await loginManager.WithdrawMembership()
                    await MainActor.run {
                        rm.currentState = .login
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

enum SheetState {
    case medium
    case large
    
    static func up(_ state: inout SheetState) {
        switch state {
            case .large:
                return
            case .medium:
                state = .large
        }
    }
    
    static func down(_ state: inout SheetState) {
        switch state {
            case .large:
                state = .medium
            case .medium:
                return
        }
    }
}
