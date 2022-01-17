import UIKit
import Firebase
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override init() {
        FirebaseApp.configure()
    }
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            Messaging.messaging().apnsToken = deviceToken
            super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
        
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
            Messaging.messaging().appDidReceiveMessage(userInfo)
    }
}
