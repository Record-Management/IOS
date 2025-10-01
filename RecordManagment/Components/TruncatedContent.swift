import SwiftUI

struct TruncatedContent: View {
    @State private var isTruncated: Bool? = nil
    @Binding var expanded: Bool
    var content: String
    var lineLimit: Int
    
    var body: some View {
        Text(content)
            .typography(.p14Regular)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(expanded ? nil : lineLimit)
            .overlay(alignment: .bottomTrailing) {
                if !expanded && isTruncated == true {
                    Text("...더보기")
                        .typography(.p14Regular)
                        .onTapGesture {
                            self.expanded.toggle()
                        }
                        .background(Color.Gray._50())
                }
            }
            .background(
                ViewThatFits(in: .vertical) {
                    Text(content)
                        .typography(.p14Regular)
                        .hidden()
                        .onAppear {
                            guard isTruncated == nil else { return }
                            isTruncated = false
                        }

                    Color.clear
                        .hidden()
                        .onAppear {
                            guard isTruncated == nil else { return }
                            isTruncated = true
                        }
                }
            )
    }
}
