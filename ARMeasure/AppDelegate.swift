/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Empty application delegate class.
*/

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	// Nothing to do here. See ViewController for primary app features.
    func applicationWillTerminate(_ application: UIApplication) {
//        JSONManager.sharedInstance.saveMainJSON()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        JSONManager.sharedInstance.saveMainJSON()
    }
}

