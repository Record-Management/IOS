import SwiftUI

struct FilterDropDownView: View {
    @Binding var currentRecord: DropDownFilter
    @Binding var isFilterBox: Bool
    let fullScreenWidth: CGFloat = UIScreen.main.bounds.width

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Triangle()
                .fill(Color.Gray._100())
                .frame(width: 15, height: 10)
                .padding(.trailing, 24)

            RoundedRectangle(cornerRadius: 100)
                .fill(Color.Gray._100())
                .frame(width: fullScreenWidth * 0.47, height: 46)
                .overlay(
                    HStack {
                        ForEach(Array(DropDownFilter.allCases.enumerated()), id: \.offset) { index,filter in
                            filterItemView(item: filter)
                            
                            // 마지막 요소가 아니면 Spacer() 추가
                            if index != DropDownFilter.allCases.count - 1 {
                                Spacer()
                            }
                        }
                    }
                    .frame(height: 46)
                    .padding(8)
                )
        }
        .offset(y: 43)
    }

    // TODO: filter Box 내부 Item
    private func filterItemView(item: DropDownFilter) -> some View {
        ZStack {
            Circle()
                .fill(Color.white)
            
            if currentRecord == item {
                Circle()
                    .stroke(Color.Primary.main(), lineWidth: 1)
            }

            Image(item.getImage())
                .resizable()
                .scaledToFit()
                .padding(3)
        }
        .onTapGesture {
            withAnimation(.interactiveSpring) {
                self.currentRecord = item
                isFilterBox = false
            }
        }
    }
}
