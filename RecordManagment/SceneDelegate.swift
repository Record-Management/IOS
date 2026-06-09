import UIKit
import SwiftUI
import KakaoSDKAuth
import KakaoSDKCommon

extension Notification.Name {
    static let floatingButtonFrameChanged = Notification.Name("floatingButtonFrameChanged")
    static let floatingButtonExtendsChanged = Notification.Name("floatingButtonExtendsChanged")
    static let noGoalCardFrameChanged = Notification.Name("noGoalCardFrameChanged")
    static let checkGoalChanged = Notification.Name("checkGoalChanged")
    static let toastOnAppear = Notification.Name("toastOnAppear")
    static let alertVisibilityChanged = Notification.Name("alertVisibilityChanged")
    static let datePickerVisibilityChanged = Notification.Name("datePickerVisibilityChanged")
}

enum WindowType {
    case floating
    case toast
    case alert
    case datePicker
}

fileprivate final class PassThroughWindow: UIWindow {
    private let windowType: WindowType
    private let canCaptureTouch: (() -> Bool)?
    private var buttonFrame: CGRect = .zero
    private var cardFrame: CGRect = .zero
    private var isCardVisible: Bool = false
    
    init(windowScene: UIWindowScene, windowType: WindowType, canCaptureTouch: (() -> Bool)? = nil) {
        self.windowType = windowType
        self.canCaptureTouch = canCaptureTouch
        super.init(windowScene: windowScene)
        setupObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupObservers() {
        if windowType == .floating {
            NotificationCenter.default.addObserver(self, selector: #selector(handleFrameChange(_:)), name: .floatingButtonFrameChanged, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleCardFrameChange(_:)), name: .noGoalCardFrameChanged, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleCheckGoalChange(_:)), name: .checkGoalChanged, object: nil)
        }
    }
    
    @objc private func handleFrameChange(_ notification: Notification) {
        guard let rect = notification.object as? CGRect else { return }
        self.buttonFrame = rect
    }
    
    @objc private func handleCardFrameChange(_ notification: Notification) {
        guard let rect = notification.object as? CGRect else { return }
        self.cardFrame = rect
    }
    
    @objc private func handleCheckGoalChange(_ notification: Notification) {
        guard let isCardVisible = notification.object as? Bool else { return }
        self.isCardVisible = isCardVisible
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result: UIView?
        switch windowType {
        case .alert:
            if canCaptureTouch?() == true {
                result = super.hitTest(point, with: event)
            } else {
                result = nil
            }
            
        case .datePicker:
            // 데이트피커 시트가 프레젠트되어 있을 때만 터치를 캡처합니다.
            if rootViewController?.presentedViewController != nil {
                result = super.hitTest(point, with: event)
            } else {
                result = nil
            }
            
        case .toast:
            result = nil
            
        case .floating:
            if canCaptureTouch?() == true {
                result = super.hitTest(point, with: event)
            } else if buttonFrame.contains(point) {
                result = super.hitTest(point, with: event)
            } else if isCardVisible && cardFrame.contains(point) {
                result = super.hitTest(point, with: event)
            } else {
                result = nil
            }
        }
        
        return result
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

@MainActor
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var mainWindow: UIWindow?
    var floatingButtonWindow: UIWindow?
    var toastWindow: UIWindow?
    var alertWindow: UIWindow?
    var datePickerWindow: UIWindow?
    
    let appContainer = AppContainer()
    lazy var coordinator = Coordinator(appContainer: appContainer)
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            self.setupMainWindow(in: windowScene)
            self.setupFloatingButtonWindow(in: windowScene)
            self.setupToastWindow(in: windowScene)
            self.setupAlertWindow(in: windowScene)
            self.setupDatePickerWindow(in: windowScene)
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
    
    func setupFloatingButtonWindow(in scence: UIWindowScene) {
        let mainStore = appContainer.makeMainStore()
        let secondWindow = PassThroughWindow(windowScene: scence, windowType: .floating) { [weak mainStore] in
            mainStore?.state.isFloatingExtends ?? false
        }
        
        let rootView = FloatingView(
            store: mainStore
        )
        .environmentObject(coordinator)
            
        let secondViewController = UIHostingController(rootView: rootView)
        secondViewController.view.backgroundColor = .clear
        secondWindow.rootViewController = secondViewController
        
        secondWindow.windowLevel = .statusBar + 1
        secondWindow.isHidden = false
        
        self.floatingButtonWindow = secondWindow
    }
    
    func setupToastWindow(in scence: UIWindowScene) {
        let toastWindow = PassThroughWindow(windowScene: scence, windowType: .toast)
        
        let rootView = ToastMessage()
            .environmentObject(coordinator)
            
        let toastViewController = UIHostingController(rootView: rootView)
        toastViewController.view.backgroundColor = .clear
        toastWindow.rootViewController = toastViewController
        
        toastWindow.windowLevel = .statusBar + 2
        toastWindow.isHidden = false
        
        self.toastWindow = toastWindow
    }
    
    func setupAlertWindow(in scence: UIWindowScene) {
        let alertStore = appContainer.makeAlertStore()
        let alertWindow = PassThroughWindow(windowScene: scence, windowType: .alert) { [weak alertStore] in
            alertStore?.state.isPresented ?? false
        }
        
        let rootView = PresentAlertView(
            store: alertStore
        )
        .environmentObject(coordinator)
        
        let alertViewController = UIHostingController(rootView: rootView)
        alertViewController.view.backgroundColor = .clear
        alertWindow.rootViewController = alertViewController
        
        alertWindow.windowLevel = .alert
        alertWindow.isHidden = false
        
        self.alertWindow = alertWindow
    }
    
    func setupDatePickerWindow(in scence: UIWindowScene) {
        // datePickerWindow는 rootViewController?.presentedViewController != nil 검사만 수행하므로 클로저는 nil로 처리
        let datePickerWindow = PassThroughWindow(windowScene: scence, windowType: .datePicker)
        
        let rootView = PresentDatePickerView(
            store: appContainer.makeRecordStore()
        )
        .environmentObject(coordinator)
        
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .clear
        datePickerWindow.rootViewController = hostingController
        
        datePickerWindow.windowLevel = .alert - 1
        datePickerWindow.isHidden = false
        
        self.datePickerWindow = datePickerWindow
    }
}
