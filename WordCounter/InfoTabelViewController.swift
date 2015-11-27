//
//  InfoTabelViewController.swift
//  WordCounter
//
//  Created by Arefly on 6/7/2015.
//  Copyright (c) 2015 Arefly. All rights reserved.
//

import UIKit
import Foundation
import MessageUI

class InfoTabelViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet var versionTitle: UILabel!
    @IBOutlet var buildSubtitle: UILabel!
    
    @IBOutlet var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[提示] Info Tabel View Controller 之 super.viewDidLoad() 已加載")
        
        let dictionary = NSBundle.mainBundle().infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        
        versionTitle.text = String.localizedStringWithFormat(NSLocalizedString("About.Title.Text.Version", comment: "Version %@"), version)
        buildSubtitle.text = String.localizedStringWithFormat(NSLocalizedString("About.Subtitle.Text.Build", comment: "Build %@"), build)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("[提示] Info Table View Controller 之 super.viewWillAppear() 已加載")

        /*var tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Info View Controller")
        
        var builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])*/
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 0){
            if(indexPath.row == 0){
                print("[提示] 用戶已按下分享按鈕")
                
                let textToShare = NSLocalizedString("Global.Text.ShareMessage", comment: "Hi! Still counting words 1 by 1? Get Word Counter Tools on App Store today!")
                
                if let appStoreURL = BasicConfig().appStoreShortUrl {
                    let objectsToShare = [textToShare, appStoreURL]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    
                    self.presentViewController(activityVC, animated: true, completion: nil)
                    
                    if let popView = activityVC.popoverPresentationController {
                        print("[提示] 須使用 popView")
                        popView.sourceView = tableView
                        popView.sourceRect = tableView.cellForRowAtIndexPath(indexPath)!.frame
                    }
                }
                
                /*println("[提示] 準備發送分享按鈕統計數據")
                var tracker = GAI.sharedInstance().defaultTracker
                var event = GAIDictionaryBuilder.createEventWithCategory("Info Action", action: "Share Cell Clicked", label: nil, value: nil)
                tracker.send(event.build() as [NSObject : AnyObject])*/
            }
            if(indexPath.row == 1){
                print("[提示] 用戶已按下評分按鈕")
                
                UIApplication.sharedApplication().openURL(BasicConfig().appStoreReviewUrl!)
                
                /*println("[提示] 準備發送評分按鈕統計數據")
                var tracker = GAI.sharedInstance().defaultTracker
                var event = GAIDictionaryBuilder.createEventWithCategory("Info Action", action: "Rate Cell Clicked", label: nil, value: nil)
                tracker.send(event.build() as [NSObject : AnyObject])*/
            }
            if(indexPath.row == 2){
                print("[提示] 用戶已按下查看其它Apps按鈕")
                
                UIApplication.sharedApplication().openURL(BasicConfig().otherAppsByMe!)
                
                /*println("[提示] 準備發送「查看其它Apps」按鈕統計數據")
                var tracker = GAI.sharedInstance().defaultTracker
                var event = GAIDictionaryBuilder.createEventWithCategory("Info Action", action: "Check other Apps Cell Clicked", label: nil, value: nil)
                tracker.send(event.build() as [NSObject : AnyObject])*/
            }
        }
        if(indexPath.section == 1){
            if(indexPath.row == 1){
                let mailComposerVC = MFMailComposeViewController()
                mailComposerVC.mailComposeDelegate = self
                
                mailComposerVC.setToRecipients(["eflyjason@gmail.com"])
                mailComposerVC.setSubject("About Word Counter Tools")
                mailComposerVC.setMessageBody("", isHTML: false)
                
                if MFMailComposeViewController.canSendMail() {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(mailComposerVC, animated: true, completion: nil)
                    }
                }
                
                /*println("[提示] 準備發送發送郵件按鈕統計數據")
                var tracker = GAI.sharedInstance().defaultTracker
                var event = GAIDictionaryBuilder.createEventWithCategory("Info Action", action: "Email eflyjason@gmail.com Cell Clicked", label: nil, value: nil)
                tracker.send(event.build() as [NSObject : AnyObject])*/
            }
            
            if(indexPath.row == 2){
                UIApplication.sharedApplication().openURL(NSURL(string: "http://www.arefly.com/")!)
                
                /*println("[提示] 準備發送發送郵件按鈕統計數據")
                var tracker = GAI.sharedInstance().defaultTracker
                var event = GAIDictionaryBuilder.createEventWithCategory("Info Action", action: "Open AREFLY.COM Cell Clicked", label: nil, value: nil)
                tracker.send(event.build() as [NSObject : AnyObject])*/
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError?) {
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            print("Mail cancelled")
        case MFMailComposeResultSaved.rawValue:
            print("Mail saved")
        case MFMailComposeResultSent.rawValue:
            print("Mail sent")
        case MFMailComposeResultFailed.rawValue:
            print("Mail sent failure: \(error!.localizedDescription)")
        default:
            break
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}