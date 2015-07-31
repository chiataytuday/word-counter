//
//  InfoTabelViewController.swift
//  WordCounter
//
//  Created by Arefly on 6/7/2015.
//  Copyright (c) 2015年 Arefly. All rights reserved.
//

import UIKit
import Foundation
import MessageUI

class InfoTabelViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet var versionTitle: UILabel!
    @IBOutlet var buildSubtitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("[提示] Info Tabel View Controller 之 super.viewDidLoad() 已加載")
        
        let dictionary = NSBundle.mainBundle().infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        
        versionTitle.text = String.localizedStringWithFormat(NSLocalizedString("VERSION_TITLE", comment: "Version %@"), version)
        buildSubtitle.text = String.localizedStringWithFormat(NSLocalizedString("BUILD_SUBTITLE", comment: "Build %@"), build)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 0){
            if(indexPath.row == 0){
                println("[提示] 用戶已按下分享按鈕")
                
                let textToShare = NSLocalizedString("SHARE_MESSAGE", comment: "Hi! Still counting words 1 by 1? Get Word Counter Tools on App Store today!")
                
                if let appStoreURL = NSURL(string: "http://apple.co/1VR0O76") {
                    let objectsToShare = [textToShare, appStoreURL]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    
                    self.presentViewController(activityVC, animated: true, completion: nil)
                    
                    if let popView = activityVC.popoverPresentationController {
                        println("[提示] 須使用 popView")
                        let v = tableView as UIView
                        popView.sourceView = v
                        popView.sourceRect = v.bounds
                    }
                }
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
                    self.presentViewController(mailComposerVC, animated: true, completion: nil)
                }
            }
            
            if(indexPath.row == 2){
                UIApplication.sharedApplication().openURL(NSURL(string: "http://www.arefly.com/")!)
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    @IBAction func shareButtonAction(sender: AnyObject) {
        
    }
    
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
        switch result.value {
        case MFMailComposeResultCancelled.value:
            println("Mail cancelled")
        case MFMailComposeResultSaved.value:
            println("Mail saved")
        case MFMailComposeResultSent.value:
            println("Mail sent")
        case MFMailComposeResultFailed.value:
            println("Mail sent failure: \(error.localizedDescription)")
        default:
            break
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}