//
//  AppDelegate.swift
//  MusicSearch
//
//  Created by Rey Isla on 9/23/17.
//  Copyright © 2017 Rey Isla. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        guard let splitViewController = window!.rootViewController as? UISplitViewController else { return true }
        
        // Show both master and detail view controllers if possible e.g. iPads
        splitViewController.preferredDisplayMode = .allVisible
        
        splitViewController.delegate = self
        
        return true
    }
    
}

// MARK: - Split View Delegate
extension AppDelegate: UISplitViewControllerDelegate {
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController,
            let topAsDetailController = secondaryAsNavController.topViewController
                as? MusicSearchResultDetailViewController else { return false }
        
        if topAsDetailController.song == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller
            // will be discarded. This allows us to show the Search screen first instead of the Detail screen on
            // smaller devices that can't display both screens.
            return true
        }
        
        return false
    }
}

