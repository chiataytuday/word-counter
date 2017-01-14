//
//  AppDelegate.swift
//  WordCounter
//
//  Created by Arefly on 5/7/2015.
//  Copyright (c) 2015 Arefly. All rights reserved.
//

import UIKit
import CoreData
import Async
import CocoaLumberjack
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	var adMobBannerView: GADBannerView!
	var adMobRequest: GADRequest!

	let defaults = UserDefaults.standard

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		DDLogInfo("準備加載 didFinishLaunchingWithOptions")


		if let userUrl = launchOptions?[UIApplicationLaunchOptionsKey.url] as? URL {
			self.callToSetClipBoard(userUrl.absoluteString)
		}

		if let textBeforeEnterBackground = defaults.string(forKey: "textBeforeEnterBackground") {
			if(!textBeforeEnterBackground.isEmpty){
				self.callToSetTextBeforeEnterBackground()
			}
		}


		adMobBannerView = GADBannerView.init(adSize: kGADAdSizeSmartBannerPortrait)
		adMobBannerView.translatesAutoresizingMaskIntoConstraints = false
		adMobBannerView.isHidden = true
		adMobBannerView.alpha = 0
		adMobBannerView.adUnitID = BasicConfig.adMobUnitId

		adMobRequest = GADRequest()
		adMobRequest.testDevices = [
			kGADSimulatorID,
			"898636d9efb529b668ee419acdcf5a76",         // Arefly's iPhone
			"02e875974400ad52909c9d4a1899aa96",         // Arefly's iPad
		]




		/**** Log & Log Color START ****/
		setenv("XcodeColors", "YES", 0)

		#if DEBUG
			let logLevel = DDLogLevel.all
		#else
			let logLevel = DDLogLevel.Info
		#endif

		DDLog.add(DDTTYLogger.sharedInstance(), with: logLevel) // TTY = Xcode console
		DDLog.add(DDASLLogger.sharedInstance(), with: logLevel) // ASL = Apple System Logs

		DDTTYLogger.sharedInstance().logFormatter = CustomLogFormatter()

		DDTTYLogger.sharedInstance().colorsEnabled = true
		DDTTYLogger.sharedInstance().setForegroundColor(UIColor.lightGray, backgroundColor: nil, for: .verbose)
		DDTTYLogger.sharedInstance().setForegroundColor(UIColor.gray, backgroundColor: nil, for: .debug)
		DDTTYLogger.sharedInstance().setForegroundColor(UIColor.black, backgroundColor: nil, for: .info)


		let fileLogger: DDFileLogger = DDFileLogger() // File Logger
		fileLogger.rollingFrequency = TimeInterval(60*60*24)  // 24 hours
		fileLogger.logFileManager.maximumNumberOfLogFiles = 7
		DDLog.add(fileLogger, with: .warning)
		/**** Log & Log Color END ****/




		// Override point for customization after application launch.
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
		DDLogInfo("準備加載 applicationWillResignActive")

	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		DDLogInfo("準備加載 applicationDidEnterBackground")

	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
		DDLogInfo("準備加載 applicationWillEnterForeground")

	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		DDLogInfo("準備加載 applicationDidBecomeActive")

	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		DDLogInfo("準備加載 applicationWillTerminate")


		// Saves changes in the application's managed object context before the application terminates.
		self.saveContext()
	}

	// MARK: - Core Data stack

	lazy var applicationDocumentsDirectory: URL = {
		// The directory the application uses to store the Core Data store file. This code uses a directory named "com.arefly.WordCounter" in the application's documents Application Support directory.
		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return urls[urls.count-1]
	}()

	lazy var managedObjectModel: NSManagedObjectModel = {
		// The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
		let modelURL = Bundle.main.url(forResource: "WordCounter", withExtension: "momd")!
		return NSManagedObjectModel(contentsOf: modelURL)!
	}()

	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
		// The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
		// Create the coordinator and store
		var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		let url = self.applicationDocumentsDirectory.appendingPathComponent("WordCounter.sqlite")
		var error: NSError? = nil
		var failureReason = "There was an error creating or loading the application's saved data."
		do {
			try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
		} catch var error1 as NSError {
			error = error1
			coordinator = nil
			// Report any error we got.
			var dict = [String: AnyObject]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
			dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
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

	func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
		if let userUrl = String(describing: url) as String? {
			DDLogVerbose("用戶輸入的網址爲：\(userUrl)")
			callToSetClipBoard(userUrl)
			return true
		}
		return false
	}

	func callToSetClipBoard(_ url: String) {
		DDLogDebug("準備加載 callToSetClipBoard(\(url))")
		if (url == "count://fromClipBoard") {
			Async.main {                // 於主線執行
				DDLogVerbose("已準備將用戶剪貼簿內容設定爲TextView之內容")
				NotificationCenter.default.post(name: NSNotification.Name("com.arefly.WordCounter.setContentFromClipBoard"), object: self)
			}
		}
	}

	func callToSetTextBeforeEnterBackground() {
		DDLogDebug("準備加載 callToSetTextBeforeEnterBackground")
		Async.main {                // 於主線執行
			DDLogVerbose("已準備將進入背景前的內容設定爲TextView之內容")
			NotificationCenter.default.post(name: NSNotification.Name("com.arefly.WordCounter.setContentToTextBeforeEnterBackground"), object: self)
		}
	}

}
