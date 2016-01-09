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
        print("[提示] Info Tabel View Controller 之 super.viewDidLoad() 已加載")
        
        self.title = NSLocalizedString("About.NavBar.Title", comment: "About")
        
        
        let dictionary = NSBundle.mainBundle().infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        
        let versionText = String.localizedStringWithFormat(NSLocalizedString("About.Title.Text.Version", comment: "Version %@"), version)
        let buildText = String.localizedStringWithFormat(NSLocalizedString("About.Subtitle.Text.Build", comment: "Build %@"), build)
        
        tableContent.append(NSLocalizedString("About.Table.Section0.Content", comment: "Section 0 Content").componentsSeparatedByString("--"))
        tableContent.append(String.localizedStringWithFormat(NSLocalizedString("About.Table.Section1.Content", comment: "Section 1 Content"), versionText, buildText).componentsSeparatedByString("--"))
        
        
        headerContent = NSLocalizedString("About.Table.Header.Content", comment: "Header Content").componentsSeparatedByString("--")
        footerContent = NSLocalizedString("About.Table.Footer.Content", comment: "Footer Content").componentsSeparatedByString("--")
        
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("[提示] Info Table View Controller 之 super.viewWillAppear() 已加載")
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
            case 3:
                print("[提示] 用戶已按下捐款按鈕")
                
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
                    print("[提示] 用戶已按下取消按鈕")
                }))
                
                presentViewController(donateAlert, animated: true, completion: nil)
                
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
    
    
    // MARK: - IAP Related func
    func donateMoney(amount: Int) {
        print("[提示] 用戶已選擇捐款 \(amount) 美元")
        
        print("[提示] 準備獲取產品信息")
        print("[提示] 用戶canMakePayments()值爲 \(SKPaymentQueue.canMakePayments())")
        
        if (SKPaymentQueue.canMakePayments()){
            getProductInfo("WordCounter.Donation.\(amount)")
        }else{
            alertPlzEnableIAP()
        }
    }
    
    func getProductInfo(id: String) {
        print("[提示] 獲取產品信息中")
        
        MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
        
        
        let request = SKProductsRequest(productIdentifiers: [id])
        
        request.delegate = self
        request.start()
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        print("[提示] 已成功向蘋果請求內購產品信息")
        
        MBProgressHUD.hideAllHUDsForView(self.view.window, animated: true)
        
        let count: Int = response.products.count
        if (count > 0) {
            //var validProducts = response.products
            let validProduct: SKProduct = response.products[0]
            print("[提示] 已獲取內購產品信息：")
            print("[提示] 產品ID：\(validProduct.productIdentifier)")
            print("[提示] 本地化標題：\(validProduct.localizedTitle)")
            print("[提示] 本地化描述：\(validProduct.localizedDescription)")
            print("[提示] 價格：\(validProduct.price)")
            buyProduct(validProduct)
        } else {
            print("[警告] 請求信息失敗")
        }
    }
    
    func buyProduct(product: SKProduct) {
        print("[提示] 發送內購產品信息至蘋果中")
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    func request(request: SKRequest, didFailWithError error: NSError) {
        print("[警告] 內購失敗：\(error.localizedDescription)")
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("[提示] 已獲取蘋果回應")
        
        for transaction: AnyObject in transactions {
            if let trans: SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .Purchased:
                    print("[提示] 用戶內購成功")
                    print("[提示] 產品ID：\((transaction as! SKPaymentTransaction).payment.productIdentifier)")
                    self.deliverProduct(transaction as! SKPaymentTransaction)
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                case .Failed:
                    print("[警告] 用戶內購失敗")
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                default:
                    break
                }
            }
        }
    }
    
    func deliverProduct(transaction: SKPaymentTransaction) {
        print("[提示] 用戶已捐款成功！")
        print("[提示] 產品ID：\(transaction.payment.productIdentifier)")
        
        finishDonating()
        
        let donateSuccessAlert = UIAlertController(
            title: NSLocalizedString("About.Alert.DonateSuccess.Title", comment: "Thank you!"),
            message: NSLocalizedString("About.Alert.DonateSuccess.Content", comment: "We have received your donation!\nAD is hidden now! :)"),
            preferredStyle: .Alert)
        donateSuccessAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Done", comment: "Done"), style: .Cancel, handler: { (action: UIAlertAction) in
            print("[提示] 用戶已按下完成按鈕")
        }))
        presentViewController(donateSuccessAlert, animated: true, completion: nil)
    }
    
    func restoreDonate() {
        print("[提示] 用戶已按下「恢復購買」按鈕")
        
        MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
        
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        print("[提示] 已完成恢復先前之內購記錄")
        
        MBProgressHUD.hideAllHUDsForView(self.view.window, animated: true)
        
        var willShowSuccess = false
        
        for transaction: SKPaymentTransaction in queue.transactions {
            if (transaction.payment.productIdentifier).rangeOfString("WordCounter.Donation.") != nil {
                print("[提示] 用戶已恢復捐款")
                print("[提示] 內購ID：\(transaction.payment.productIdentifier)")
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
                print("[提示] 用戶已按下完成按鈕")
            }))
            presentViewController(restoreSuccessAlert, animated: true, completion: nil)
        }
    }
    
    func finishDonating() {
        defaults.setBool(true, forKey: "noAd")
    }
    
    func alertPlzEnableIAP() {
        print("[提示] 準備顯示「請開啓內購」通知")
        let iapDisabledAlert = UIAlertController(title: NSLocalizedString("About.Alert.IapDisabledAlert.Title", comment: "IAP is not allowed!"), message: NSLocalizedString("About.Alert.IapDisabledAlert.Content", comment: "Please enable in-app purchases in Settings app."), preferredStyle: .Alert)
        iapDisabledAlert.addAction(UIAlertAction(title: NSLocalizedString("About.Alert.IapDisabledAlert.Button.OpenSettings", comment: "Open Settings"), style: .Default, handler: { alertAction in
            print("[提示] 用戶已按下前往「設定」按鈕")
            let url: NSURL? = NSURL(string: UIApplicationOpenSettingsURLString)
            if url != nil{
                UIApplication.sharedApplication().openURL(url!)
            }
        }))
        iapDisabledAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Close", comment: "Close"), style: .Cancel, handler: { alertAction in
            print("[提示] 用戶已按下關閉按鈕")
        }))
        self.presentViewController(iapDisabledAlert, animated: true, completion: nil)
    }
    
    
    // MARK: - Mail Related func
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}