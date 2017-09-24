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

        let splitViewController = window!.rootViewController as! UISplitViewController
        
        splitViewController.preferredDisplayMode = .allVisible
        
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count - 1]
            as! UINavigationController
        
        navigationController.topViewController!.navigationItem.leftBarButtonItem =
            splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        
        return true
    }
    
}

// MARK: - Split View Delegate

extension AppDelegate: UISplitViewControllerDelegate {
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController
            as? MusicSearchResultDetailViewController else { return false }
        
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        
        return false
    }
}

