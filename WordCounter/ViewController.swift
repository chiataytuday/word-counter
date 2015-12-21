//
//  ViewController.swift
//  WordCounter
//
//  Created by Arefly on 5/7/2015.
//  Copyright (c) 2015 Arefly. All rights reserved.
//

import UIKit
import Foundation
import iAd
import Async
import MBProgressHUD
import EAIntroView

class ViewController: UIViewController, UITextViewDelegate, ADBannerViewDelegate, EAIntroDelegate {
    
    // MARK: - Basic var
    let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    
    var wordCounterClass = WordCounter()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let sharedData = NSUserDefaults(suiteName: "group.com.arefly.WordCounter")
    
    // MARK: - Init var
    var countNumNow = 0
    
    var iAdHeight: CGFloat = 0.0
    
    // MARK: - IBOutlet var
    @IBOutlet var tv: UITextView!
    
    @IBOutlet var topBarCountButton: UIBarButtonItem!
    
    // MARK: - keyboardButton var
    var keyBoardToolBar = UIToolbar()
    
    var showedKeyboardButtons = [String: Bool]()
    
    var countingKeyboardBarButtonItemsNames = [String]()
    var countingKeyboardBarButtonItems = [String: UIBarButtonItem]()
    
    var stableKeyboardBarButtonItemsNames = [String]()
    var stableKeyboardBarButtonItems = [String: UIBarButtonItem]()
    
    // MARK: - Bool var
    var keyboardShowing = false
    var iAdShowing = false
    
    var appFirstLaunch = false
    var appJustUpdate = false
    
    var presentingOtherView = false
    
    //var isZhUser = false
    
    // MARK: - UI var
    var tvPlaceholderLabel: UILabel!
    
    // MARK: Welcome page var
    var intro = EAIntroView()
    
    // MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[提示] View Controller 之 super.viewDidLoad() 已加載")
        
        self.title = NSLocalizedString("Main.NavBar.Title", comment: "Word Counter")
        
        
        if(isAppFirstLaunch()){
            appFirstLaunch = true
        }
        
        
        let version: String = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        
        if(defaults.objectForKey("nowVersion") == nil){
            defaults.setValue(version, forKey: "nowVersion")
            appFirstLaunch = true
        }else{
            if(defaults.stringForKey("nowVersion") != version){
                appJustUpdate = true
                defaults.setValue(version, forKey: "nowVersion")
            }
        }
        
        
        self.tv.delegate = self
        self.tv.layoutManager.allowsNonContiguousLayout = false

        
        
        tvPlaceholderLabel = UILabel()
        tvPlaceholderLabel.text = NSLocalizedString("Global.TextView.PlaceHolder.Text", comment: "Type or paste here...")
        tvPlaceholderLabel.font = UIFont.systemFontOfSize(tv.font!.pointSize)
        tvPlaceholderLabel.sizeToFit()
        tv.addSubview(tvPlaceholderLabel)
        tvPlaceholderLabel.frame.origin = CGPointMake(5, tv.font!.pointSize / 2)
        tvPlaceholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        tvPlaceholderLabel.hidden = !tv.text.isEmpty
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("[提示] View Controller 之 super.viewWillAppear() 已加載")
        
        addToolBarToKeyboard()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "doAfterRotate", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        //2015-12-11: Change to DidEnterBackgroundNotification as it is more suiable in Slide Over view
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "endEditing", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setContentFromClipBoard", name: "com.arefly.WordCounter.getContentFromClipBoard", object: nil)
        
        doAfterRotate()
        //checkScreenWidthToSetButton()
        
        
        if(defaults.objectForKey("appLaunchTimes") == nil){
            defaults.setInteger(1, forKey: "appLaunchTimes")
        }else{
            defaults.setInteger(defaults.integerForKey("appLaunchTimes") + 1, forKey: "appLaunchTimes")
        }
        print("[提示] 已設定appLaunchTimes值爲\(defaults.integerForKey("appLaunchTimes"))")
        
        if(defaults.objectForKey("everShowPresentReviewAgain") == nil){
            defaults.setBool(true, forKey: "everShowPresentReviewAgain")
        }
        
        
        //appJustUpdate = true
        if(defaults.objectForKey("appLaunchTimesAfterUpdate") == nil){
            defaults.setInteger(-1, forKey: "appLaunchTimesAfterUpdate")
        }
        if(appJustUpdate){
            defaults.setInteger(1, forKey: "appLaunchTimesAfterUpdate")
        }
        
        if(defaults.integerForKey("appLaunchTimesAfterUpdate") != -1){
            defaults.setInteger(defaults.integerForKey("appLaunchTimesAfterUpdate") + 1, forKey: "appLaunchTimesAfterUpdate")
        }
        print("[提示] 已設定appLaunchTimesAfterUpdate值爲\(defaults.integerForKey("appLaunchTimesAfterUpdate"))")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("[提示] View Controller 之 super.viewDidAppear() 已加載")
        
        appDelegate.bannerView.delegate = self
        view.addSubview(appDelegate.bannerView)
        
        let viewsDictionary = ["bannerView": appDelegate.bannerView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bannerView]|", options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[bannerView]|", options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
        
        
        if( (appFirstLaunch) || (appJustUpdate) ){
            presentingOtherView = true
            
            presentIntroView()
        }
        
        if( (iAdShowing) && (iAdHeight > 0.0) ){
            self.tv.contentInset.bottom = iAdHeight
            self.tv.scrollIndicatorInsets.bottom = iAdHeight
        //}else if (self.tv.contentInset.bottom != 0){
        }else{
            self.tv.contentInset.bottom = 0
            self.tv.scrollIndicatorInsets.bottom = 0
        }
        
        //defaults.setBool(true, forKey: "everShowPresentReviewAgain")
        
        //var everShowPresentReviewAgain = defaults.boolForKey("everShowPresentReviewAgain")
        //var appLaunchTimes = defaults.integerForKey("appLaunchTimes")
        
        print("[提示] everShowPresentReviewAgain的值爲"+String(stringInterpolationSegment: defaults.boolForKey("everShowPresentReviewAgain")))
        if(defaults.boolForKey("everShowPresentReviewAgain")){
            if(!presentingOtherView){
                print("[提示] appLaunchTimes的值爲\(defaults.integerForKey("appLaunchTimes"))")
                //defaults.setInteger(8, forKey: "appLaunchTimes")
                if(defaults.integerForKey("appLaunchTimes") % 9 == 0){
                    presentingOtherView = true
                    
                    presentReviewAlert()
                    //defaults.setInteger(defaults.integerForKey("appLaunchTimes") + 1, forKey: "appLaunchTimes")
                }
            }
        }
        
        
        if(defaults.integerForKey("appLaunchTimesAfterUpdate") != -1){
            if(!presentingOtherView){
                print("[提示] appLaunchTimesAfterUpdate的值爲\(defaults.integerForKey("appLaunchTimesAfterUpdate"))")
                if(defaults.integerForKey("appLaunchTimesAfterUpdate") % 10 == 0){
                    presentingOtherView = true
                    
                    presentUpdateReviewAlert()
                    //defaults.setInteger(defaults.integerForKey("appLaunchTimes") + 1, forKey: "appLaunchTimes")
                }
            }
        }
        
        if(!presentingOtherView){
            startEditing()
        }
    }
   
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("[提示] View Controller 之 super.viewWillDisappear() 已加載")
        
        appDelegate.bannerView.removeFromSuperview()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "com.arefly.WordCounter.getContentFromClipBoard", object: nil)
        
        //NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        endEditing()
    }
    
    // MARK: - Screen config func
    func checkScreenWidthToSetButton () {
        print("[提示] 準備使用 checkScreenWidthToSetButton() 函數")
        
        showedKeyboardButtons = [
            "Word": false,
            "Character": false,
            "Sentence": false,
            "Paragraph": false,
        ]
        
        let bounds = UIApplication.sharedApplication().keyWindow?.bounds
        let width = bounds!.size.width
        let height = bounds!.size.height
        print("[提示] 屏幕高度：\(height)、屏幕寬度：\(width)")
        
        switch width {
        case 0..<330:
            showedKeyboardButtons["Word"] = false
            showedKeyboardButtons["Character"] = false
            showedKeyboardButtons["Sentence"] = true
            showedKeyboardButtons["Paragraph"] = false
            break
        case 330..<750:
            showedKeyboardButtons["Word"] = false
            showedKeyboardButtons["Character"] = true
            showedKeyboardButtons["Sentence"] = true
            showedKeyboardButtons["Paragraph"] = false
            break
        default:
            showedKeyboardButtons["Word"] = true
            showedKeyboardButtons["Character"] = true
            showedKeyboardButtons["Sentence"] = true
            showedKeyboardButtons["Paragraph"] = true
        }
        
        updateToolBar()
        
        //updateTextViewCounting()
        textViewDidChange(self.tv)      // Call textViewDidChange manually
    }
    
    func doAfterRotate () {
        print("[提示] -- 已呼叫 doAfterRotate --")
        
        if(iAdShowing){
            iAdHeight = CGRectGetHeight(appDelegate.bannerView.frame)
        }
        print("[提示] 已設定iAd高度：\(iAdHeight)")
        
        if (!keyboardShowing){
            if( (iAdShowing) && (iAdHeight > 0.0) ){
                self.tv.contentInset.bottom = iAdHeight
                self.tv.scrollIndicatorInsets.bottom = iAdHeight
                //}else if (self.tv.contentInset.bottom != 0){
            }else{
                self.tv.contentInset.bottom = 0
                self.tv.scrollIndicatorInsets.bottom = 0
            }
        }
        
        checkScreenWidthToSetButton()
    }
    
    // MARK: - Keyboard func
    func keyboardShow(n: NSNotification) {
        keyboardShowing = true
        
        setTextViewSize(n)
        
        checkScreenWidthToSetButton()
        
        //updateTextViewCounting()
        textViewDidChange(self.tv)
    }
    
    func setTextViewSize (n: NSNotification) {
        if (keyboardShowing) {
            let d = n.userInfo!
            var r = (d[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            r = self.tv.convertRect(r, fromView:nil)
            self.tv.contentInset.bottom = r.size.height
            self.tv.scrollIndicatorInsets.bottom = r.size.height
        }
        
        //self.tv.contentInset.top = 0
        //self.tv.scrollIndicatorInsets.top = 0
    }
    
    func keyboardHide(n: NSNotification) {
        let selectedRangeBeforeHide = tv.selectedRange
        
        keyboardShowing = false
        
        if( (iAdShowing) && (iAdHeight > 0.0) ){
            self.tv.contentInset.bottom = iAdHeight
            self.tv.scrollIndicatorInsets.bottom = iAdHeight
        }else{
            self.tv.contentInset.bottom = 0
            self.tv.scrollIndicatorInsets.bottom = 0
        }
        
        self.tv.contentInset.top = 0
        self.tv.scrollIndicatorInsets.top = 0
        
        tv.scrollRangeToVisible(selectedRangeBeforeHide)
        tv.selectedRange = selectedRangeBeforeHide
    }
    
    func addToolBarToKeyboard(){
        keyBoardToolBar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 44))
        //keyBoardToolBar = UIToolbar()
        keyBoardToolBar.barStyle = .Default
        //keyBoardToolBar.translatesAutoresizingMaskIntoConstraints = false
        
        keyBoardToolBar.translucent = false
        keyBoardToolBar.barTintColor = UIColor(colorLiteralRed: (247/255), green: (247/255), blue: (247/255), alpha: 1)     //http://stackoverflow.com/a/34290370/2603230
        
        
        stableKeyboardBarButtonItemsNames = [String]()      //Empty stableKeyboardBarButtonItemsNames first
        
        stableKeyboardBarButtonItems["FlexSpace"] = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        stableKeyboardBarButtonItemsNames.append("FlexSpace")
        
        stableKeyboardBarButtonItems["Done"] = UIBarButtonItem(title: "", style: .Done, target: self, action: "doneButtonAction")
        stableKeyboardBarButtonItemsNames.append("Done")
        
        let infoButton: UIButton = UIButton(type: UIButtonType.InfoLight)
        infoButton.addTarget(self, action: "infoButtonAction", forControlEvents: UIControlEvents.TouchUpInside)
        stableKeyboardBarButtonItems["Info"] = UIBarButtonItem(customView: infoButton)
        stableKeyboardBarButtonItemsNames.append("Info")
        
        
        countingKeyboardBarButtonItemsNames = ["Word", "Character", "Sentence", "Paragraph"]
        for name in countingKeyboardBarButtonItemsNames {
            countingKeyboardBarButtonItems[name] = UIBarButtonItem(title: "", style: .Plain, target: self, action: "countButtonClickedFromKeyboardBarButtonItem")
            countingKeyboardBarButtonItems[name]!.tintColor = UIColor.blackColor()
        }
        
        
        updateToolBar()
    }
    
    func updateToolBar() {
        var barItems = [UIBarButtonItem]()
        
        for name in countingKeyboardBarButtonItemsNames {
            if(showedKeyboardButtons[name] == true){
                barItems.append(countingKeyboardBarButtonItems[name]!)
            }
        }
        for name in stableKeyboardBarButtonItemsNames {
            barItems.append(stableKeyboardBarButtonItems[name]!)
        }
        
        keyBoardToolBar.setItems(barItems, animated: true)
        
        keyBoardToolBar.setNeedsLayout()
        
        /*keyBoardToolBar.sizeToFit()
        keyBoardToolBar.frame.size.height = 44*/
        
        self.tv.inputAccessoryView = keyBoardToolBar
        
        stableKeyboardBarButtonItems["Done"]!.title = ""
        stableKeyboardBarButtonItems["Done"]!.title = NSLocalizedString("Global.Button.Done", comment: "Done")
        
        updateTextViewCounting()
    }
    
    // MARK: - Textview related func
    /*
    func endEditingIfFullScreen() {
        let isFullScreen = CGRectEqualToRect((UIApplication.sharedApplication().keyWindow?.bounds)!, UIScreen.mainScreen().bounds)
        
        print("[提示] 目前窗口是否處於全屏狀態：\(isFullScreen)")
        
        if(isFullScreen){
            endEditing()
        }
    }
    */
    
    func endEditing() {
        self.tv.resignFirstResponder()
        //self.tv.endEditing(true)
        //self.view.endEditing(true)
    }
    
    func startEditing() {
        self.tv.becomeFirstResponder()
    }
    
    func clearContent() {
        endEditing()
        
        tv.text = ""
        textViewDidChange(self.tv)      // Call textViewDidChange manually
        
        //updateTextViewCounting()
        
        doAfterRotate()
    }
    
    func textViewDidChange(textView: UITextView) {
        tvPlaceholderLabel.hidden = !textView.text.isEmpty
        
        updateTextViewCounting()
    }
    
    func updateTextViewCounting () {
        //var wordTitle = ""
        
        var titles = [
            "Word": "-MUST_NEED-",
            "Character": "",
            "Sentence": "",
            "Paragraph": "",
        ]
        
        Async.background {
            for (name, _) in titles {
                if( (self.showedKeyboardButtons[name] == true) || (titles[name] == "-MUST_NEED-") ){
                    titles[name] = WordCounter().getCountString(self.tv.text, type: name)
                }
            }
            }.main {
                self.topBarCountButton.title = titles["Word"]
                
                for name in self.countingKeyboardBarButtonItemsNames {
                    self.countingKeyboardBarButtonItems[name]!.title = ""
                    self.countingKeyboardBarButtonItems[name]!.title = titles[name]
                }
                
                print(titles["Sentence"])
        }
    }
    
    func setContentFromClipBoard() {
        print("[提示] -- 已開始使用 setContentFromClipBoard() 函數 --")
        
        if let clipBoard = UIPasteboard.generalPasteboard().string {
            print("[提示] 已獲取用戶剪貼簿內容：\(clipBoard)")
            tv.text = clipBoard
            //updateTextViewCounting()
            textViewDidChange(self.tv)      // Call textViewDidChange manually
        }
    }
    
    
    // MARK: - Button action func
    @IBAction func clearButtonClicked(sender: AnyObject) {
        let keyboardShowingBefore = keyboardShowing
        
        endEditing()
        
        let clearContentAlert = UIAlertController(
            title: NSLocalizedString("Global.Alert.BeforeClear.Title", comment: "Clear all content?"),
            message: NSLocalizedString("Global.Alert.BeforeClear.Content", comment: "WARNING: This action is irreversible!"),
            preferredStyle: .Alert)
        
        clearContentAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Yes", comment: "Yes"), style: .Default, handler: { (action: UIAlertAction) in
            print("[提示] 用戶已按下確定清空按鈕")
            self.clearContent()
            self.startEditing()
        }))
        
        clearContentAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Close", comment: "Close"), style: .Cancel, handler: { (action: UIAlertAction) in
            print("[提示] 用戶已按下取消清空按鈕")
            if(keyboardShowingBefore){
                self.startEditing()
            }
        }))
        
        presentViewController(clearContentAlert, animated: true, completion: nil)
    }
    
    func infoButtonAction () {
        self.performSegueWithIdentifier("goInfo", sender: nil)
    }
    
    func countButtonClickedFromKeyboardBarButtonItem() {
        countResultButtonAction()
    }
    
    
    func countResultButtonAction () {
        let keyboardShowingBefore = keyboardShowing
        
        endEditing()
        
        let progressHUD = MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
        progressHUD.labelText = NSLocalizedString("Global.ProgressingHUD.Label.Counting", comment: "Counting...")
        
        var titles = [
            "Word": "",
            "Character": "",
            "Sentence": "",
            "Paragraph": "",
        ]
        
        Async.background {
            for name in self.countingKeyboardBarButtonItemsNames {
                titles[name] = WordCounter().getCountString(self.tv.text, type: name)
            }
            }.main {
                MBProgressHUD.hideAllHUDsForView(self.view.window, animated: true)
                
                let alertTitle = NSLocalizedString("Global.Alert.Counter.Title", comment: "Counter")
                
                var message = ""
                
                for (index, name) in self.countingKeyboardBarButtonItemsNames.enumerate() {
                    let localizedString = "Global.Alert.Counter.Content.\(name)"
                    
                    message += String.localizedStringWithFormat(NSLocalizedString(localizedString, comment: "Localized string for every counting."), titles[name]!)
                    
                    if(index != self.countingKeyboardBarButtonItemsNames.count-1) {
                        message += "\n"
                    }
                }
                
                let countingResultAlert = UIAlertController(title: alertTitle, message: message, preferredStyle: .Alert)
                countingResultAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Done", comment: "Done"), style: .Cancel, handler: { (action: UIAlertAction) in
                    print("[提示] 用戶已按下確定按鈕")
                    if(keyboardShowingBefore){
                        self.startEditing()
                    }
                }))
                self.presentViewController(countingResultAlert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func topBarCountingButtonClicked(sender: AnyObject) {
        countResultButtonAction()
    }
    
    func doneButtonAction() {
        endEditing()
    }
    
    
    
    // MARK: - iAd func
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        print("[提示] 用戶已點擊iAd廣告")
        
        return true
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        print("[提示] 用戶已關閉iAd廣告")
    }
    
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        print("[提示] iAd已成功加載！")
        //appDelegate.bannerView.hidden = false
        
        if(!iAdShowing){
            UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.appDelegate.bannerView.alpha = 1
                }, completion: {
                    (value: Bool) in
                    self.appDelegate.bannerView.hidden = false
            })
            
            iAdShowing = true
            
            iAdHeight = CGRectGetHeight(appDelegate.bannerView.frame)
            
            if(!keyboardShowing){
                self.tv.contentInset.bottom = iAdHeight
                self.tv.scrollIndicatorInsets.bottom = iAdHeight
            }
        }
        
        //self.canDisplayBannerAds = true
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        print("[警告] iAd加載錯誤！")

        if(iAdShowing){
            UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.appDelegate.bannerView.alpha = 0
                }, completion: {
                    (value: Bool) in
                    self.appDelegate.bannerView.hidden = true
            })
            
            
            iAdShowing = false
            
            iAdHeight = 0.0
            
            if(!keyboardShowing){
                self.tv.contentInset.bottom = 0
                self.tv.scrollIndicatorInsets.bottom = 0
            }
        }
        
        
        //self.canDisplayBannerAds = false
    }
    
    // MARK: - Intro View
    func presentIntroView() {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
        }
        
        let screenWidth = self.view.bounds.size.width
        let screenHeight = self.view.bounds.size.height
        
        let contentImages = [
            "1-3-ActionExtension-Introduction.png",
            "1-3-ActionExtension-How.png",
            "1-3-MoreCountingType.png",
            "1-3-ImproveTodayWidget.png",
            "1-3-About.png",
        ]
        
        let contentTitleTexts = [
            NSLocalizedString("Welcome.Version.1-3.Title.ActionExtension.Introduction", comment: ""),
            NSLocalizedString("Welcome.Version.1-3.Title.ActionExtension.How", comment: ""),
            NSLocalizedString("Welcome.Version.1-3.Title.MoreCountingType", comment: ""),
            NSLocalizedString("Welcome.Version.1-3.Title.ImproveTodayWidget", comment: ""),
            NSLocalizedString("Welcome.Global.Title.About", comment: "Thanks!"),
        ]
        
        let contentDetailTexts = [
            NSLocalizedString("Welcome.Version.1-3.Text.ActionExtension.Introduction", comment: ""),
            NSLocalizedString("Welcome.Version.1-3.Text.ActionExtension.How", comment: ""),
            NSLocalizedString("Welcome.Version.1-3.Text.MoreCountingType", comment: ""),
            NSLocalizedString("Welcome.Version.1-3.Text.ImproveTodayWidget", comment: ""),
            NSLocalizedString("Welcome.Global.Text.About", comment: ""),
        ]
        
        var introPages = [EAIntroPage]()
        
        for (index, _) in contentTitleTexts.enumerate() {
            
            let page = EAIntroPage()
            page.title = contentTitleTexts[index]
            page.desc = contentDetailTexts[index]
            
            if (index == contentImages.count-1) {
                //About Content
                page.descFont = UIFont(name: (page.descFont?.fontName)!, size: 12)
            }
            
            //print("WOW!: \(page.titlePositionY)")
            
            let titlePositionFromBottom = page.titlePositionY
            
            let imageView = UIImageView(image: UIImage(named: contentImages[index]))
            imageView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight-titlePositionFromBottom-50)
            imageView.contentMode = .ScaleAspectFit
            
            page.titleIconView = imageView
            page.titleIconPositionY = 30
            
            page.bgColor = self.view.tintColor
            
            introPages.append(page)
        }
        
        intro = EAIntroView(frame: self.view.bounds, andPages: introPages)
        intro.delegate = self
        intro.showInView(self.view, animateDuration: 0.5)
        intro.showFullscreen()
        intro.skipButton.setTitle(NSLocalizedString("Welcome.Global.Button.Skip", comment: "Skip"), forState: .Normal)
        intro.pageControlY = 20
    }
    
    func introDidFinish(introView: EAIntroView!) {
        presentingOtherView = false
        appFirstLaunch = false
        startEditing()
    }
    
    // MARK: - General func
    func didBecomeActive() {
        doAfterRotate()
        
        if(!presentingOtherView){
            startEditing()
        }
    }
    
    func isAppFirstLaunch() -> Bool{          //檢測App是否首次開啓
        if let _ = defaults.stringForKey("isAppAlreadyLaunchedOnce"){
            print("[提示] App於本機並非首次開啓")
            return false
        }else{
            defaults.setBool(true, forKey: "isAppAlreadyLaunchedOnce")
            print("[提示] App於本機首次開啓")
            return true
        }
    }
    
    func presentReviewAlert() {
        let reviewAlert = UIAlertController(
            title: NSLocalizedString("Global.Alert.PlzRate.Title", comment: "Thanks!"),
            message: String.localizedStringWithFormat(
                NSLocalizedString("Global.Alert.PlzRate.Content", comment: "You have used Word Counter Tools for %d times! Love it? Can you take a second to rate our app?"),
                defaults.integerForKey("appLaunchTimes")),
            preferredStyle: .Alert)
        
        reviewAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Alert.PlzRate.Button.Yes", comment: "Sure!"), style: .Default, handler: { (action: UIAlertAction) in
            print("[提示] 用戶已按下發表評論按鈕")
            self.defaults.setBool(false, forKey: "everShowPresentReviewAgain")
            UIApplication.sharedApplication().openURL(BasicConfig().appStoreReviewUrl!)
            self.presentingOtherView = false
        }))
        
        reviewAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Alert.PlzRate.Button.Later", comment: "Not now"), style: .Default, handler: { (action: UIAlertAction) in
            print("[提示] 用戶已按下以後再說按鈕")
            self.defaults.setBool(true, forKey: "everShowPresentReviewAgain")
            self.startEditing()
            self.presentingOtherView = false
        }))
        
        reviewAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Alert.PlzRate.Button.Cancel", comment: "No, thanks!"), style: .Cancel, handler: { (action: UIAlertAction) in
            print("[提示] 用戶已按下永遠再不顯示按鈕")
            self.defaults.setBool(false, forKey: "everShowPresentReviewAgain")
            self.startEditing()
            self.presentingOtherView = false
        }))
        
        presentViewController(reviewAlert, animated: true, completion: nil)
    }
    
    func presentUpdateReviewAlert() {
        let reviewAlert = UIAlertController(
            title: NSLocalizedString("Global.Alert.PlzRateUpdate.Title", comment: "Thanks for update!"),
            message: String.localizedStringWithFormat(
                NSLocalizedString("Global.Alert.PlzRateUpdate.Content", comment: "You have used Word Counter Tools for %1$d times since you updated to Version %2$@! Love this update? Can you take a second to rate our app?"),
                defaults.integerForKey("appLaunchTimesAfterUpdate"),
                NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
            ),
            preferredStyle: .Alert)
        
        reviewAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Alert.PlzRateUpdate.Button.Yes", comment: "Sure!"), style: .Default, handler: { (action: UIAlertAction) in
            print("[提示] 用戶已按下發表評論按鈕")
            self.defaults.setInteger(-1, forKey: "appLaunchTimesAfterUpdate")
            UIApplication.sharedApplication().openURL(BasicConfig().appStoreReviewUrl!)
            self.presentingOtherView = false
        }))
        
        reviewAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Alert.PlzRateUpdate.Button.Later", comment: "Not now"), style: .Default, handler: { (action: UIAlertAction) in
            print("[提示] 用戶已按下以後再說按鈕")
            self.startEditing()
            self.presentingOtherView = false
        }))
        
        reviewAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Alert.PlzRateUpdate.Button.Cancel", comment: "No, thanks!"), style: .Cancel, handler: { (action: UIAlertAction) in
            print("[提示] 用戶已按下永遠再不顯示按鈕")
            self.defaults.setInteger(-1, forKey: "appLaunchTimesAfterUpdate")
            self.startEditing()
            self.presentingOtherView = false
        }))
        
        presentViewController(reviewAlert, animated: true, completion: nil)
    }
}