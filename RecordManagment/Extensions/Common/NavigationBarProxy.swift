import UIKit
import SwiftUI

struct NavigationBarProxy: UIViewControllerRepresentable {
    var callback: (UIView, UINavigationBar, UIEdgeInsets) -> Void
    private let proxyController = MyViewController()
    
    func makeUIViewController(context: Context) -> UIViewController {
        proxyController.callback = callback
        return proxyController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    typealias UIViewControllerType = UIViewController
    
    private class MyViewController: UIViewController {
        var callback: (UIView, UINavigationBar, UIEdgeInsets) -> Void = { _, _, _ in }
                
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let navigationController = self.navigationController {
                let safeAreaInsets = navigationController.view.safeAreaInsets
                self.callback(navigationController.view, navigationController.navigationBar, safeAreaInsets)
            }
        }
    }
}
