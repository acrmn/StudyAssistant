//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var orientationLock = UIInterfaceOrientationMask.portrait

    override init() {
        super.init()
        FirebaseApp.configure()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Google Sign In sharedInstance
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        //MARK: Fix Transparent Nav Bar iOS 15
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(named: "PrimaryBlue")
            appearance.titleTextAttributes = [.foregroundColor : UIColor.white]
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
        // Assign Delegate for Push Notifications
        UNUserNotificationCenter.current().delegate = self
        
        //MARK: Check for Logged User
        if UserDefaults.standard.bool(forKey: Constants.loginKey) == true {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let loginVC = mainStoryboard.instantiateViewController(withIdentifier: "loginVC") as! LogInViewController
            let tabBarController = mainStoryboard.instantiateViewController(withIdentifier: "tabBarVC") as! UITabBarController
            self.window?.rootViewController = tabBarController
            
            let navController = mainStoryboard.instantiateViewController(withIdentifier: "navVC") as! UINavigationController
            let navController2 = mainStoryboard.instantiateViewController(withIdentifier: "navVC2") as! UINavigationController
            let navController3 = mainStoryboard.instantiateViewController(withIdentifier: "navVC3") as! UINavigationController
            let navController4 = mainStoryboard.instantiateViewController(withIdentifier: "navVC4") as! UINavigationController
            
            let eventVC = mainStoryboard.instantiateViewController(withIdentifier: "eventsVC") as! EventsViewController
            
            tabBarController.viewControllers = [navController, navController2, navController3, navController4]
            tabBarController.selectedViewController = navController
            tabBarController.present(eventVC, animated: true)
        }
        return true
    }
    
    // MARK: Google Sign In
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
      -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }
    
    // MARK: Force Portrait
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    // MARK: Enter App via Push Notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let idNotification = response.notification.request.identifier
        
        let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let tabBarController = mainStoryboard.instantiateViewController(withIdentifier: "tabBarVC") as! UITabBarController
        self.window?.rootViewController = tabBarController
        
        let navController = mainStoryboard.instantiateViewController(withIdentifier: "navVC") as! UINavigationController
        let navController2 = mainStoryboard.instantiateViewController(withIdentifier: "navVC2") as! UINavigationController
        let navController3 = mainStoryboard.instantiateViewController(withIdentifier: "navVC3") as! UINavigationController
        let navController4 = mainStoryboard.instantiateViewController(withIdentifier: "navVC4") as! UINavigationController
        
        let eventDetailVC = mainStoryboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
        eventDetailVC.selectedEventId = idNotification
        
        tabBarController.viewControllers = [navController, navController2, navController3, navController4]
        tabBarController.selectedViewController = navController
        tabBarController.present(eventDetailVC, animated: true)
        
        completionHandler()
    }
}
