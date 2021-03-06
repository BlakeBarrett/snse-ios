//
//  AppDelegate.swift
//  snse
//
//  Created by Blake Barrett on 11/8/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private static let minimumMacOSWidth = 600.0
    private static let minimumMacOSHeight = 900.0
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let scene = scene as? UIWindowScene {
            scene.sizeRestrictions?.minimumSize =
                CGSize(
                    width: AppDelegate.minimumMacOSWidth,
                    height: AppDelegate.minimumMacOSHeight
                )
            scene.sizeRestrictions?.maximumSize =
                CGSize(
                    width: CGFloat.greatestFiniteMagnitude,
                    height: CGFloat.greatestFiniteMagnitude
                )
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
            
            if  let window = window,
                let splitViewController = window.rootViewController as? UISplitViewController,
                let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as? UINavigationController,
                let topViewController = navigationController.topViewController {
                
                topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
                // Add a translucent background to the primary view controller.
                splitViewController.primaryBackgroundStyle = .sidebar
            }
        }
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        blur()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        unBlur()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "snse")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

extension AppDelegate {
    
    static let blurEffectTag = 1337
    
    func blur() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = window!.frame
        blurEffectView.tag = AppDelegate.blurEffectTag
        
        self.window?.addSubview(blurEffectView)
    }
    
    func unBlur() {
        self.window?.viewWithTag(AppDelegate.blurEffectTag)?.removeFromSuperview()
    }
}

extension AppDelegate {
    
    // For handling Siri shortcuts
    // https://developer.apple.com/documentation/sirikit/soup_chef_accelerating_app_interactions_with_shortcuts
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        super.restoreUserActivityState(activity)
    }
}

extension AppDelegate {
    
    @available(iOS 13.0, *)
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        
        let newSentimentCommand = UIKeyCommand(title: NSLocalizedString("New", comment: "new"),
                                               image: nil,
                                               action: #selector(newSentiment),
                                               input: "N",
                                               modifierFlags: .command,
                                               propertyList: nil)
        
        let newMenu = UIMenu(title: NSLocalizedString("", comment: ""),
                             image: nil,
                             identifier: UIMenu.Identifier("com.blakebarrett.snse.app.new"),
                             options: .displayInline,
                             children: [newSentimentCommand])
        
        builder.insertChild(newMenu, atStartOfMenu: .file)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        let currentlyPresentedRestorationIdentifier = window?.rootViewController?.children.last?.restorationIdentifier
        
        switch action {
            case #selector(newSentiment):
                return currentlyPresentedRestorationIdentifier != ViewController.identifier
            default:
                return super.canPerformAction(action, withSender: sender)
        }
    }
    
    @objc
    public func newSentiment() {
        if let viewController = ViewController.getViewController(with: ViewController.identifier) {
            window?.rootViewController?.present(viewController, animated: true)
        }
    }
}

extension AppDelegate {
    
    @available(iOS 13.0, *)
    override func validate(_ command: UICommand) {
        super.validate(command)
    }
}
