import SwiftUI

struct SeedDaySheet<Content: View>: View {
    @EnvironmentObject var coordinator: Coordinator
    let config = SeedDaySheetConfig()
    @ViewBuilder var content: () -> Content
    // Binding
    @Binding var safeArea: EdgeInsets
    @Binding var selectedDetent: PresentationDetent
    // View Properties
    @State private var animationState: Bool = false
    /// toolbar 바로 아래까지의 sheet 최대 높이
    private var maxSheetHeight: CGFloat {
        UIScreen.main.bounds.height
        - (safeArea.top - safeArea.bottom)
        - config.navigationBarHeight
        - config.cornerRadius   
    }
    
    init(
        safeArea: Binding<EdgeInsets>,
        selectedDetent: Binding<PresentationDetent>,
        @ViewBuilder content: @escaping() -> Content
    ) {
        self.content = content
        self._selectedDetent = selectedDetent
        self._safeArea = safeArea
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ZStack{
                VStack(spacing: 0) {
                    content()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .background(config.backgroundColor)
            }
        }
        .frame(maxWidth: .infinity)
        .background(config.backgroundColor)
        .interactiveDismissDisabled(true)
        .presentationDetents([
            .fraction(Constant.Main.presentationDetent),
            .height(maxSheetHeight)
        ], selection: $selectedDetent)
        .onChange(of: selectedDetent) { _, newValue in
            animationState.toggle()
        }
        .presentationBackgroundInteraction(.enabled(upThrough: .height(maxSheetHeight)))
        .presentationCornerRadius(animationState ? 0 : config.cornerRadius)
    }
}

struct SeedDaySheetConfig {
    let cornerRadius: CGFloat = 20
    let backgroundColor: Color = .white
    /// inline NavigationBar 높이 (iPhone 기준 44pt)
    let navigationBarHeight: CGFloat = 44
}

struct SeedDaySheetStyle<InnerContent: View>: ViewModifier {
    @Binding var safeArea: EdgeInsets
    @Binding var showSheet: Bool
    @Binding var selectedDetent: PresentationDetent
    @ViewBuilder var innerContent: () -> InnerContent
    
    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: EdgeInsets.self) {
                $0.safeAreaInsets
            } action: {
                print($0)
                safeArea = $0
            }
            .sheet(isPresented: $showSheet) {
                SeedDaySheet(
                    safeArea: $safeArea,
                    selectedDetent: $selectedDetent,
                    content: innerContent
                )
            }
    }
}

