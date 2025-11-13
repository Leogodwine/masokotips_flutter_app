import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    // Keep a reference to the launch screen view controller
    private var launchScreenView: UIViewController?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Show the launch screen while Flutter initializes
        showLaunchScreen()
        
        // Register plugins
        GeneratedPluginRegistrant.register(with: self)
        
        // Hide the launch screen after a delay to ensure smooth transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.hideLaunchScreen()
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func showLaunchScreen() {
        guard let launchScreen = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController() else {
            return
        }
        
        // Configure the launch screen view controller
        launchScreenView = launchScreen
        launchScreenView?.view.frame = window?.bounds ?? UIScreen.main.bounds
        
        // Add the launch screen to the window
        if let launchView = launchScreenView?.view {
            window?.addSubview(launchView)
        }
    }
    
    private func hideLaunchScreen() {
        UIView.animate(withDuration: 0.3, animations: {
            self.launchScreenView?.view.alpha = 0
        }) { _ in
            self.launchScreenView?.view.removeFromSuperview()
            self.launchScreenView = nil
        }
    }
}
