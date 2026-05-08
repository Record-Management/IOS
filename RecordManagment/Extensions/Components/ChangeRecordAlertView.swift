import SwiftUI

struct ChangeRecordAlertView: View {
    @Binding var isAlert: Bool
    @Binding var currentRecord: SeedType
    @Binding var selectedRecord: SeedType
    
    var body: some View {
        ZStack {
            Color(hex: "#222222").opacity(0.5)
                .onTapGesture {
                    withAnimation(.interactiveSpring) {
                        self.isAlert = false
                    }
                }
            
            VStack {
                Text("어떤 하루로 변경할까요?")
                    .typography(.p18SemiBold)
                    .frame(maxWidth: .infinity)
                VStack(spacing: 10) {
                    ForEach(SeedType.getTypes(current: currentRecord), id: \.id) { record in
                        recordBox(record.getTitle(), icon: record.id, color: record.getColor(), size: record.getSize())
                            .contentShape(Rectangle())
                            .onTapGesture { // select Record
                                withAnimation(.interactiveSpring) {
                                    self.selectedRecord = record
                                }
                            }
                    }
                }
                .padding(.vertical, 24)
                
                Button("변경하기") {
                    guard selectedRecord != .none else { return }
                    self.currentRecord = selectedRecord
                    self.selectedRecord = .none
                    // closed screen
                    self.isAlert = false
                }
                .seedDaysButtonStyle(type: selectedRecord != .none ? .success : .normal, state: .primary)
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .padding(.horizontal, 32)
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        }
        .ignoresSafeArea()
    }
    
    private func recordBox(_ title: String, icon: String, color: Color, size: CGSize) -> some View {
        let isActive = selectedRecord.getTitle() == title
        
        return HStack {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 50, height: 50)
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width, height: size.height)
            }
            .padding(.trailing)
            
            Text(title)
                .typography(.p16SemiBold)
                .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: isActive ? "checkmark.circle.fill" : "checkmark.circle")
                .foregroundStyle(isActive ? Color.Primary.main() : Color.Gray._100())
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 1)
                .foregroundStyle(isActive ? Color.Primary.main() : Color.Gray._100())
        }
    }
}
