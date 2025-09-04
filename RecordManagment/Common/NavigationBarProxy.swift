import UIKit
import SwiftUI

struct NavigationBarProxy: UIViewControllerRepresentable {
    var callback: (UIView, UINavigationBar) -> Void
    private let proxyController = MyViewController()
    
    func makeUIViewController(context: Context) -> UIViewController {
        proxyController.callback = callback
        return proxyController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    typealias UIViewControllerType = UIViewController
    
    private class MyViewController: UIViewController {
        var callback: (UIView, UINavigationBar) -> Void = { _, _ in }
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let navigationController = self.navigationController {
                self.callback(navigationController.view, navigationController.navigationBar)
            }
        }
    }
}
