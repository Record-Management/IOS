import SwiftUI

struct SystemSettingAlert: View {
    @Binding var isOn: Bool
    var body: some View {
        if !isOn {
            HStack {
                Text("현재 알림이 꺼져있어요.\n지금 바로 알림을 켜주세요!")
                    .typography(.p14Regular)
                    .foregroundStyle(.white)
                Spacer()
                HStack(spacing: 4) {
                    Group {
                        Text("알림 설정")
                            .typography(.p14SemiBold)
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(Color.Primary.main())
                }
                .padding()
                .background(.white)
                .clipShape(.rect(cornerRadius: 100))
                .onTapGesture {
                    Task { await openAppSettings() }
                }
            }
            .padding()
            .background(Color.Primary.main())
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private func openAppSettings() async {
        await withCheckedContinuation { continuation in
            guard let url = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(url) else {
                Log.info("설정 화면을 열 수 없습니다.")
                return
            }
            UIApplication.shared.open(url)
            continuation.resume()
        }
    }
}
