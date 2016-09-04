//
//  InfoTabelViewController.swift
//  WordCounter
//
//  Created by Arefly on 6/7/2015.
//  Copyright (c) 2015 Arefly. All rights reserved.
//

import UIKit
import Foundation
import StoreKit
import MessageUI
import Async
import CocoaLumberjack
import MBProgressHUD

class InfoTabelViewController: UITableViewController, SKPaymentTransactionObserver, SKProductsRequestDelegate, MFMailComposeViewControllerDelegate {
    
    // MARK: - Basic var
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // MARK: - Table Content var
    var tableContent = [[String]]()
    var headerContent = [String]()
    var footerContent = [String]()
    
    // MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("準備加載 Info Tabel View Controller 之 viewDidLoad")
        
        self.title = NSLocalizedString("About.NavBar.Title", comment: "About")
        
        
        let dictionary = NSBundle.mainBundle().infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        
        let versionText = String.localizedStringWithFormat(NSLocalizedString("About.Title.Text.Version", comment: "Version %@"), version)
        let buildText = String.localizedStringWithFormat(NSLocalizedString("About.Subtitle.Text.Build", comment: "Build %@"), build)
        
        tableContent.append(NSLocalizedString("About.Table.Section0.Content", comment: "Section 0 Content").componentsSeparatedByString("--"))
        tableContent.append(String.localizedStringWithFormat(NSLocalizedString("About.Table.Section1.Content", comment: "Section 1 Content"), versionText, buildText).componentsSeparatedByString("--"))
        
        
        headerContent = NSLocalizedString("About.Table.Header.Content", comment: "Header Content").componentsSeparatedByString("--")
        
        
        let startYear = 2015
        let currentYear = NSCalendar(identifier: NSCalendarIdentifierGregorian)!.components([.Year], fromDate: NSDate()).year
        
        var copyrightYears = "\(startYear)"
        if(currentYear > startYear){
            copyrightYears = "\(startYear)-\(currentYear)"
        }
        
        footerContent = String.localizedStringWithFormat(NSLocalizedString("About.Table.Footer.Content", comment: "Footer Content"), copyrightYears).componentsSeparatedByString("--")
        
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        DDLogInfo("準備加載 Info Table View Controller 之 viewWillAppear")
    }
    
    // MARK: - Table func
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableContent[section].count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableContent.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerContent[section]
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return footerContent[section]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellContent = tableContent[indexPath.section][indexPath.row].componentsSeparatedByString("||")
        
        let cell = tableView.dequeueReusableCellWithIdentifier("InfoCell", forIndexPath: indexPath)
        cell.textLabel?.text = cellContent[0]
        cell.detailTextLabel?.text = cellContent[1]
        
        if(indexPath.section == 0){
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                DDLogVerbose("用戶已按下分享按鈕")
                
                let textToShare = NSLocalizedString("Global.Text.ShareMessage", comment: "Hi! Still counting words one by one? Get Word Counter Tools on App Store today!")
                
                if let appStoreURL = BasicConfig.appStoreShortUrl {
                    let objectsToShare = [textToShare, appStoreURL]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    
                    Async.main {
                        self.presentViewController(activityVC, animated: true, completion: nil)
                    }
                    
                    if let popView = activityVC.popoverPresentationController {
                        DDLogVerbose("須使用 popView")
                        popView.sourceView = tableView
                        popView.sourceRect = tableView.cellForRowAtIndexPath(indexPath)!.frame
                    }
                }
                
                break
            case 1:
                DDLogVerbose("用戶已按下評分按鈕")
                
                UIApplication.sharedApplication().openURL(BasicConfig.appStoreReviewUrl!)
                
                break
            case 2:
                DDLogVerbose("用戶已按下查看其它Apps按鈕")
                
                UIApplication.sharedApplication().openURL(BasicConfig.otherAppsByMe!)
                
                break
            case 3:
                DDLogVerbose("用戶已按下捐款按鈕")
                
                let donateValues = [1, 5, 10, 25, 100]
                
                let donateAlert = UIAlertController(
                    title: NSLocalizedString("About.Alert.Donate.Title", comment: ""),
                    message: NSLocalizedString("About.Alert.Donate.Content", comment: ""),
                    preferredStyle: .Alert)
                
                for donateValue in donateValues {
                    donateAlert.addAction(UIAlertAction(title: String.localizedStringWithFormat(NSLocalizedString("About.Alert.Donate.Button.Donate", comment: "Donate US $%d!"), donateValue), style: .Default, handler: { (action: UIAlertAction) in
                        self.donateMoney(donateValue)
                    }))
                }
                donateAlert.addAction(UIAlertAction(title: NSLocalizedString("About.Alert.Donate.Button.Restore", comment: "(Restore purchases)"), style: .Default, handler: { (action: UIAlertAction) in
                    self.restoreDonate()
                }))
                donateAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Close", comment: "Close"), style: .Cancel, handler: { (action: UIAlertAction) in
                    DDLogVerbose("用戶已按下取消按鈕")
                }))
                
                Async.main {
                    self.presentViewController(donateAlert, animated: true, completion: nil)
                }
                
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
                    Async.main {
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
                    DDLogVerbose("用戶已按下確定打開Github按鈕")
                    UIApplication.sharedApplication().openURL(NSURL(string: "http://bit.ly/WordCounterGithub")!)
                }))
                
                showGithubAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Close", comment: "Close"), style: .Cancel, handler: { (action: UIAlertAction) in
                    DDLogVerbose("用戶已按下取消按鈕")
                }))
                
                Async.main {
                    self.presentViewController(showGithubAlert, animated: true, completion: nil)
                }
                
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
    
    
    // MARK: - IAP Related func
    func donateMoney(amount: Int) {
        DDLogDebug("準備加載 donateMoney(\(amount))")
        DDLogVerbose("即：準備獲取產品信息")
        
        DDLogVerbose("用戶canMakePayments()值爲 \(SKPaymentQueue.canMakePayments())")
        
        if (SKPaymentQueue.canMakePayments()){
            getProductInfo("WordCounter.Donation.\(amount)")
        }else{
            alertPlzEnableIAP()
        }
    }
    
    func getProductInfo(id: String) {
        DDLogDebug("準備加載 getProductInfo(\(id))")
        DDLogVerbose("即：準備獲取產品信息")
        
        switchHudWithoutTitle(true)
        
        
        let request = SKProductsRequest(productIdentifiers: [id])
        
        request.delegate = self
        request.start()
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        DDLogDebug("準備加載 productsRequest: didReceiveResponse")
        DDLogVerbose("即：已獲取蘋果回覆內購產品信息")
        
        switchHudWithoutTitle(false)
        
        let count: Int = response.products.count
        if (count > 0) {
            //var validProducts = response.products
            let validProduct: SKProduct = response.products[0]
            DDLogVerbose("已獲取內購產品信息：")
            DDLogVerbose("產品ID：\(validProduct.productIdentifier)")
            DDLogVerbose("本地化標題：\(validProduct.localizedTitle)")
            DDLogVerbose("本地化描述：\(validProduct.localizedDescription)")
            DDLogVerbose("價格：\(validProduct.price)")
            buyProduct(validProduct)
        } else {
            DDLogError("請求信息失敗")
        }
    }
    func request(request: SKRequest, didFailWithError error: NSError) {
        DDLogDebug("準備加載 request: didFailWithError")
        DDLogError("即：無法獲取蘋果回覆內購產品信息：\(error.localizedDescription)")
        
        switchHudWithoutTitle(false)
    }
    
    func buyProduct(product: SKProduct) {
        DDLogDebug("準備加載 buyProduct(\(product))")
        DDLogVerbose("即：發送內購產品信息至蘋果中")
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        DDLogDebug("準備加載 paymentQueue: updatedTransactions")
        DDLogVerbose("即：已獲取蘋果回應")
        
        for transaction: AnyObject in transactions {
            if let trans: SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .Purchased:
                    DDLogInfo("用戶內購成功")
                    DDLogVerbose("產品ID：\((transaction as! SKPaymentTransaction).payment.productIdentifier)")
                    self.deliverProduct(transaction as! SKPaymentTransaction)
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                case .Failed:
                    DDLogError("用戶內購失敗")
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                default:
                    break
                }
            }
        }
    }
    
    func deliverProduct(transaction: SKPaymentTransaction) {
        DDLogDebug("準備加載 deliverProduct")
        DDLogVerbose("即：用戶已捐款成功！")
        DDLogVerbose("產品ID：\(transaction.payment.productIdentifier)")
        
        finishDonating()
        
        let donateSuccessAlert = UIAlertController(
            title: NSLocalizedString("About.Alert.DonateSuccess.Title", comment: "Thank you!"),
            message: NSLocalizedString("About.Alert.DonateSuccess.Content", comment: "We have received your donation!\nAD is hidden now! :)"),
            preferredStyle: .Alert)
        donateSuccessAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Done", comment: "Done"), style: .Cancel, handler: { (action: UIAlertAction) in
            DDLogVerbose("用戶已按下完成按鈕")
        }))
        
        Async.main {
            self.presentViewController(donateSuccessAlert, animated: true, completion: nil)
        }
    }
    
    func restoreDonate() {
        DDLogDebug("準備加載 restoreDonate")
        DDLogVerbose("即：用戶已按下「恢復購買」按鈕")
        
        switchHudWithoutTitle(true)
        
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
        DDLogDebug("準備加載 paymentQueue: restoreCompletedTransactionsFailedWithError")
        DDLogError("即：恢復內購失敗：\(error.localizedDescription)")
        
        switchHudWithoutTitle(false)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        DDLogDebug("準備加載 paymentQueueRestoreCompletedTransactionsFinished")
        DDLogError("即：已完成恢復先前之內購記錄")
        
        switchHudWithoutTitle(false)
        
        var willShowSuccess = false
        
        for transaction: SKPaymentTransaction in queue.transactions {
            if (transaction.payment.productIdentifier).rangeOfString("WordCounter.Donation.") != nil {
                DDLogDebug("用戶已恢復捐款")
                DDLogVerbose("內購ID：\(transaction.payment.productIdentifier)")
                finishDonating()
                
                willShowSuccess = true
            }
            SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
        }
        
        if(willShowSuccess){
            let restoreSuccessAlert = UIAlertController(
                title: NSLocalizedString("About.Alert.RestoreSuccess.Title", comment: "Thank you!"),
                message: NSLocalizedString("About.Alert.RestoreSuccess.Content", comment: "Your donation was restored!\nAD is hidden now! :)"),
                preferredStyle: .Alert)
            restoreSuccessAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Done", comment: "Done"), style: .Cancel, handler: { (action: UIAlertAction) in
                DDLogVerbose("用戶已按下完成按鈕")
            }))
            
            Async.main {
                self.presentViewController(restoreSuccessAlert, animated: true, completion: nil)
            }
        }
    }
    
    func finishDonating() {
        defaults.setBool(true, forKey: "noAd")
    }
    
    func alertPlzEnableIAP() {
        DDLogDebug("準備加載 alertPlzEnableIAP")
        DDLogVerbose("即：準備顯示「請開啓內購」通知")
        let iapDisabledAlert = UIAlertController(title: NSLocalizedString("About.Alert.IapDisabledAlert.Title", comment: "IAP is not allowed!"), message: NSLocalizedString("About.Alert.IapDisabledAlert.Content", comment: "Please enable in-app purchases in Settings app."), preferredStyle: .Alert)
        iapDisabledAlert.addAction(UIAlertAction(title: NSLocalizedString("About.Alert.IapDisabledAlert.Button.OpenSettings", comment: "Open Settings"), style: .Default, handler: { alertAction in
            DDLogVerbose("用戶已按下前往「設定」按鈕")
            let url: NSURL? = NSURL(string: UIApplicationOpenSettingsURLString)
            if url != nil{
                UIApplication.sharedApplication().openURL(url!)
            }
        }))
        iapDisabledAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Close", comment: "Close"), style: .Cancel, handler: { alertAction in
            DDLogVerbose("用戶已按下關閉按鈕")
        }))
        
        Async.main {
            self.presentViewController(iapDisabledAlert, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Mail Related func
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Other func
    func switchHudWithoutTitle(show: Bool){
        if(show){
            MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
        }else{
            MBProgressHUD.hideAllHUDsForView(self.view.window, animated: true)
        }
    }
}