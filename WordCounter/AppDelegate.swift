//
//  AppDelegate.swift
//  WordCounter
//
//  Created by Arefly on 5/7/2015.
//  Copyright (c) 2015 Arefly. All rights reserved.
//

import UIKit
import CoreData
import iAd
import Async
import CocoaLumberjack
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    var iAdBannerView: ADBannerView!
    
    var adMobBannerView: GADBannerView!
    var adMobRequest: GADRequest!
    
    let defaults = NSUserDefaults.standardUserDefaults()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        print("[提示] 準備加載 didFinishLaunchingWithOptions")
        
        if let userUrl = launchOptions?[UIApplicationLaunchOptionsURLKey] as? NSURL {
            self.callToSetClipBoard(userUrl.absoluteString)
        }
        
        if let textBeforeEnterBackground = defaults.stringForKey("textBeforeEnterBackground") {
            if(!textBeforeEnterBackground.isEmpty){
                self.callToSetTextBeforeEnterBackground()
            }
        }
        
        
        iAdBannerView = ADBannerView(adType: .Banner)
        iAdBannerView.translatesAutoresizingMaskIntoConstraints = false
        iAdBannerView.hidden = true
        iAdBannerView.alpha = 0
        
        
        adMobBannerView = GADBannerView.init(adSize: kGADAdSizeSmartBannerPortrait)
        adMobBannerView.translatesAutoresizingMaskIntoConstraints = false
        adMobBannerView.hidden = true
        adMobBannerView.alpha = 0
        adMobBannerView.adUnitID = BasicConfig().adMobUnitId
        
        adMobRequest = GADRequest()
        adMobRequest.testDevices = [
            kGADSimulatorID,
            "898636d9efb529b668ee419acdcf5a76",         // Arefly's iPhone
            "02e875974400ad52909c9d4a1899aa96",         // Arefly's iPad
        ]
        
        
        
        
        /**** Log & Log Color START ****/
        setenv("XcodeColors", "YES", 0)
        
        #if DEBUG
            let logLevel = DDLogLevel.All
        #else
            let logLevel = DDLogLevel.Info
        #endif
        
        DDLog.addLogger(DDTTYLogger.sharedInstance(), withLevel: logLevel) // TTY = Xcode console
        DDLog.addLogger(DDASLLogger.sharedInstance(), withLevel: logLevel) // ASL = Apple System Logs
        
        DDTTYLogger.sharedInstance().logFormatter = CustomLogFormatter()
        
        DDTTYLogger.sharedInstance().colorsEnabled = true
        DDTTYLogger.sharedInstance().setForegroundColor(UIColor.lightGrayColor(), backgroundColor: nil, forFlag: .Verbose)
        DDTTYLogger.sharedInstance().setForegroundColor(UIColor.grayColor(), backgroundColor: nil, forFlag: .Debug)
        DDTTYLogger.sharedInstance().setForegroundColor(UIColor.blackColor(), backgroundColor: nil, forFlag: .Info)
        
        
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = 60*60*24  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.addLogger(fileLogger, withLevel: .Warning)
        /**** Log & Log Color END ****/
        
        
        
        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        print("[提示] 準備加載 applicationWillResignActive")
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        print("[提示] 準備加載 applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        print("[提示] 準備加載 applicationWillEnterForeground")
        
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        print("[提示] 準備加載 applicationDidBecomeActive")
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("[提示] 準備加載 applicationWillTerminate")
        
        
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.arefly.WordCounter" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("WordCounter", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("WordCounter.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if let userUrl = String(url) as String? {
            print("[提示] 用戶輸入的網址爲：\(userUrl)")
            callToSetClipBoard(userUrl)
            return true
        }
        return false
    }
    
    func callToSetClipBoard(url: String) {
        print("[提示] callToSetClipBoard 接受的網址爲：\(url)")
        if (url == "count://fromClipBoard") {
            Async.main {                // 於主線執行
                print("[提示] 已準備將用戶剪貼簿內容設定爲TextView之內容")
                NSNotificationCenter.defaultCenter().postNotificationName("com.arefly.WordCounter.setContentFromClipBoard", object: self)
            }
        }
    }
    
    func callToSetTextBeforeEnterBackground() {
        print("[提示] 準備 callToSetTextBeforeEnterBackground")
        Async.main {                // 於主線執行
            print("[提示] 已準備提示用戶是否將進入背景前的內容設定爲TextView之內容")
            NSNotificationCenter.defaultCenter().postNotificationName("com.arefly.WordCounter.setContentToTextBeforeEnterBackground", object: self)
        }
    }

}