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
    
    // MARK: - IBOutlet var
    @IBOutlet var versionTitle: UILabel!
    @IBOutlet var buildSubtitle: UILabel!
    
    // MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[提示] Info Tabel View Controller 之 super.viewDidLoad() 已加載")
        
        self.title = NSLocalizedString("About.NavBar.Title", comment: "About")
        
        let dictionary = NSBundle.mainBundle().infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        
        versionTitle.text = String.localizedStringWithFormat(NSLocalizedString("About.Title.Text.Version", comment: "Version %@"), version)
        buildSubtitle.text = String.localizedStringWithFormat(NSLocalizedString("About.Subtitle.Text.Build", comment: "Build %@"), build)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("[提示] Info Table View Controller 之 super.viewWillAppear() 已加載")
    }
    
    // MARK: - Table func
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                print("[提示] 用戶已按下分享按鈕")
                
                let textToShare = NSLocalizedString("Global.Text.ShareMessage", comment: "Hi! Still counting words one by one? Get Word Counter Tools on App Store today!")
                
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
                
                break
            case 1:
                print("[提示] 用戶已按下評分按鈕")
                
                UIApplication.sharedApplication().openURL(BasicConfig().appStoreReviewUrl!)
                
                break
            case 2:
                print("[提示] 用戶已按下查看其它Apps按鈕")
                
                UIApplication.sharedApplication().openURL(BasicConfig().otherAppsByMe!)
                
                break
            default:
                //DO NOTHING
                break
            }
            break
        case 1:
            switch indexPath.row {
            case 0:
                //DO NOTHING
                break
            case 1:
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
                
                break
            case 2:
                UIApplication.sharedApplication().openURL(NSURL(string: "http://www.arefly.com/")!)
                
                break
            case 3:
                let showGithubAlert = UIAlertController(
                    title: NSLocalizedString("About.Alert.ShowGithub.Title", comment: "You are now a developer!"),
                    message: NSLocalizedString("About.Alert.ShowGithub.Content", comment: "Open the repository of Word Counter Tools on GitHub?"),
                    preferredStyle: .Alert)
                
                showGithubAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Yes", comment: "Yes"), style: .Default, handler: { (action: UIAlertAction) in
                    print("[提示] 用戶已按下確定打開Github按鈕")
                    UIApplication.sharedApplication().openURL(NSURL(string: "http://bit.ly/WordCounterGithub")!)
                }))
                
                showGithubAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Close", comment: "Close"), style: .Cancel, handler: { (action: UIAlertAction) in
                    print("[提示] 用戶已按下取消按鈕")
                }))
                
                presentViewController(showGithubAlert, animated: true, completion: nil)
                
                break
            default:
                //DO NOTHING
                break
            }
            break
        default:
            //DO NOTHING
            break
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Related func
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