import UIKit
import SwiftUI
import KakaoSDKAuth
import KakaoSDKCommon

extension Notification.Name {
    static let floatingButtonFrameChanged = Notification.Name("floatingButtonFrameChanged")
    static let floatingButtonExtendsChanged = Notification.Name("floatingButtonExtendsChanged")
}

fileprivate final class PassThroughWindow: UIWindow {
    private var buttonFrame: CGRect = .zero
    private var isExtends: Bool = false
    
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        setupObservers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupObservers()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleFrameChange(_:)), name: .floatingButtonFrameChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleExtendsChange(_:)), name: .floatingButtonExtendsChanged, object: nil)
    }
    
    @objc private func handleFrameChange(_ notification: Notification) {
        guard let rect = notification.object as? CGRect else { return }
        self.buttonFrame = rect
    }
    
    @objc private func handleExtendsChange(_ notification: Notification) {
        guard let extends = notification.object as? Bool else { return }
        self.isExtends = extends
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 플로팅 버튼이 펼쳐진 상태(Dim 배경 노출)라면 전체 화면 터치를 가로챕니다.
        if isExtends {
            return super.hitTest(point, with: event)
        }
        
        // 플로팅 버튼 영역을 터치한 경우에만 터치를 허용하고, 그 외에는 nil을 리턴하여 MainWindow로 터치를 관통시킵니다.
        if buttonFrame.contains(point) {
            return super.hitTest(point, with: event)
        }
        
        return nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

@MainActor
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var mainWindow: UIWindow?
    var secondWindow: UIWindow?
    
    let appContainer = AppContainer()
    lazy var coordinator = Coordinator(appContainer: appContainer)
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            self.setupMainWindow(in: windowScene)
            self.setupSecondWindow(in: windowScene)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            _ = AuthController.handleOpenUrl(url: url)
        }
    }
    
    func setupMainWindow(in scence: UIWindowScene) {
        let window = UIWindow(windowScene: scence)
        
        let rootView = ContentView()
            .environmentObject(coordinator)
        
        window.rootViewController = UIHostingController(rootView: rootView)
        self.mainWindow = window
        window.makeKeyAndVisible()
    }
    
    func setupSecondWindow(in scence: UIWindowScene) {
        // 터치 관통이 가능한 PassThroughWindow를 사용합니다.
        let secondWindow = PassThroughWindow(windowScene: scence)
        
        let rootView = FloatingView(
            store: appContainer.makeMainStore()
        )
        .environmentObject(coordinator)
            
        let secondViewController = UIHostingController(rootView: rootView)
        secondViewController.view.backgroundColor = .clear
        secondWindow.rootViewController = secondViewController
        
        // 시트나 알림창보다 위에 띄우기 위해 windowLevel을 설정합니다.
        secondWindow.windowLevel = .alert + 1
        secondWindow.isHidden = false
        
        self.secondWindow = secondWindow
    }
}
