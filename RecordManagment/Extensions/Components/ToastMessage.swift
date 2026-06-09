import SwiftUI
import Combine

struct ToastMessage: View {
    @State private var visibleToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var toastTask: Task<Void, Never>? = nil
    
    var body: some View {
        ZStack {}
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                if visibleToast && !toastMessage.isEmpty {
                    Text(toastMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(Color.Gray._600())
                        .clipShape(.rect(cornerRadius: 8))
                        .offset(y: -52)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
            // 알림 수신 시 즉시 메시지 갱신 및 2초 뒤 페이드아웃 처리
            .onReceive(NotificationCenter.default.publisher(for: .toastOnAppear)) { notification in
                guard let message = notification.object as? String else { return }
                
                // 연속 토스트 유입 시 이전 디스미스 타이머 취소
                toastTask?.cancel()
                
                withAnimation(.easeInOut) {
                    self.toastMessage = message
                    self.visibleToast = true
                }
                
                toastTask = Task {
                    try? await Task.sleep(for: .seconds(2))
                    guard !Task.isCancelled else { return }
                    withAnimation(.easeInOut) {
                        self.visibleToast = false
                    }
                }
            }
    }
}

#Preview {
    ToastMessage()
}
