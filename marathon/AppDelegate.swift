//
//  AppDelegate.swift
//  marathon
//
//  Created by zhenwen on 9/8/15.
//  Copyright © 2015 zhenwen. All rights reserved.
//
// https://dribbble.com/shots/2291638-Runner

import UIKit
import marathonKit
import RealmSwift
import Bohr

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var launchedShortcutItem: AnyObject?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        print("didFinishLaunchingWithOptions")
        let navigationBar = UINavigationBar.appearance()
        navigationBar.barTintColor = appNormalColor
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.translucent = false
        
        application.statusBarStyle = .LightContent
        setupAppearance()

        // realm config
        var realmConfig = Realm.Configuration(
//            // 设置新的架构版本。这个版本号必须高于之前所用的版本号（如果您之前从未设置过架构版本，那么这个版本号设置为 0）
//            schemaVersion: 5,
//            // 设置闭包，这个闭包将会在打开低于上面所设置版本号的 Realm 数据库的时候被自动调用
//            migrationBlock: { migration, oldSchemaVersion in
//                // 目前我们还未进行数据迁移，因此 oldSchemaVersion == 0
//                if (oldSchemaVersion < 1) {
//                    // 可以什么都不做！Realm 会自行检测新增和需要移除的属性，然后自动更新硬盘上的数据库结构
//                    var i = 1
//                    migration.enumerate(RunModel.className()) { oldObject, newObject in
//                        newObject!["run_id"] = Int(NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970) - i
//                        i += 1
//                    }
//                }
//                
//                if oldSchemaVersion < 2 {
//                    var i = 1
//                    migration.enumerate(RunModel.className()) { oldObject, newObject in
//                        newObject!["tmp_field"] = i
//                        i += 1
//                    }
//                }
//                
//                if oldSchemaVersion < 3 {
//                    // 移除 tmp_field 属性
//                }
//                
//                if oldSchemaVersion < 4 {
//                    // 新增 locations 属性
//                }
//                
//                if oldSchemaVersion < 5 {
//                    // 移除 locationModel 中的 run 属性
//                }
//            }
        )
        realmConfig.path = realmConfig.path!.stringByDeletingLastPathComponent.stringByAppendingPathComponent("marathon").stringByAppendingPathExtension("realm")
        Realm.Configuration.defaultConfiguration = realmConfig
        
        if #available(iOS 9.0, *) {
            if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
                launchedShortcutItem = shortcutItem
                return false
            }
        }

        return true
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        completionHandler(handleShortcut(shortcutItem))
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    @available(iOS 9.0, *)
    func handleShortcut(shortcutItem: UIApplicationShortcutItem) -> Bool {
        if shortcutItem.type == "marathon.run" {
            // 进入跑步界面
            if let nav = window?.rootViewController as? UINavigationController {
                if nav.visibleViewController is HomeViewController {
                    nav.visibleViewController?.performSegueWithIdentifier("marathon.run", sender: nil)
                    return true
                }
            }
        }
        return false
    }
    
    func setupAppearance() {
        BOTableViewCell.appearance().selectedColor = UIColor(hex: "#f3a919")
        BOTableViewCell.appearance().secondaryColor = UIColor(hex: "#f3a919")
    }

}

