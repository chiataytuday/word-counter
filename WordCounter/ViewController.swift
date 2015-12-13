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

class ViewController: UIViewController, UITextViewDelegate, ADBannerViewDelegate {
    
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
    var wordKeyboardBarButtonItem: UIBarButtonItem!
    var paragraphKeyboardBarButtonItem: UIBarButtonItem!
    var characterKeyboardBarButtonItem: UIBarButtonItem!
    var paddingSpaceKeyboardBarButtonItem: UIBarButtonItem!
    var paddingWordsSpaceKeyboardBarButtonItem: UIBarButtonItem!
    
    // MARK: - Bool var
    var doNotShowCharacter = false
    var doNotShowWords = false
    
    var keyboardShowing = false
    var iAdShowing = false
    
    var appFirstLaunch = false
    var appJustUpdate = false
    
    //var isZhUser = false
    
    // MARK: - UI var
    var tvPlaceholderLabel: UILabel!
    
    // MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[提示] View Controller 之 super.viewDidLoad() 已加載")
        
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

        
        
        addToolBarToKeyboard()

        
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
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "doAfterRotate", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "doAfterRotate", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startEditing", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        //2015-12-11: Change to DidEnterBackgroundNotification as it is more suiable in Slide Over view
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "endEditing", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "presentReviewAlert", name: "com.arefly.WordCounter.presentReviewAlert", object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setContentFromClipBoard", name: "com.arefly.WordCounter.getContentFromClipBoard", object: nil)
        
        doAfterRotate()
        //checkScreenWidthToSetButton()
        
        if(defaults.objectForKey("appLaunchTimes") == nil){
            defaults.setInteger(1, forKey: "appLaunchTimes")
        }else{
            defaults.setInteger(defaults.integerForKey("appLaunchTimes") + 1, forKey: "appLaunchTimes")
        }
        print("[提示] 已設定appLaunchTimes值爲"+String(defaults.integerForKey("appLaunchTimes")))
        
        if(defaults.objectForKey("everShowPresentReviewAgain") == nil){
            defaults.setBool(true, forKey: "everShowPresentReviewAgain")
        }
        
        
        appDelegate.bannerView.delegate = self
        view.addSubview(appDelegate.bannerView)
        
        let viewsDictionary = ["bannerView": appDelegate.bannerView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bannerView]|", options: [], metrics: nil, views: viewsDictionary))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[bannerView]|", options: [], metrics: nil, views: viewsDictionary))
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("[提示] View Controller 之 super.viewDidAppear() 已加載")
        
        var presentingOtherView = false
        if( (appFirstLaunch) || (appJustUpdate) ){
            presentingOtherView = true
            
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let WelcomePageVC: WelcomePageViewController = storyboard.instantiateViewControllerWithIdentifier("WelcomePageViewController") as! WelcomePageViewController
            
            self.presentViewController(WelcomePageVC, animated: true, completion: nil)
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
                print("[提示] appLaunchTimes的值爲"+String(defaults.integerForKey("appLaunchTimes")))
                //defaults.setInteger(8, forKey: "appLaunchTimes")
                if(defaults.integerForKey("appLaunchTimes") % 9 == 0){
                    presentingOtherView = true
                    
                    presentReviewAlert()
                    defaults.setInteger(defaults.integerForKey("appLaunchTimes") + 1, forKey: "appLaunchTimes")
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
        
        //let bounds = UIScreen.mainScreen().bounds
        //let bounds = UIScreen.mainScreen().applicationFrame
        let bounds = UIApplication.sharedApplication().keyWindow?.bounds
        let width = bounds!.size.width
        let height = bounds!.size.height
        print("[提示] 屏幕高度：\(height)、屏幕寬度：\(width)")
        
        if (width < 330){
            doNotShowCharacter = true
            paddingWordsSpaceKeyboardBarButtonItem.width = 0
            characterKeyboardBarButtonItem.title = ""
            characterKeyboardBarButtonItem.enabled = false
        }else{
            doNotShowCharacter = false
            paddingSpaceKeyboardBarButtonItem.width = 5
            characterKeyboardBarButtonItem.enabled = true
            //updateTextViewCounting()
        }
        
        if (width > 750){
            doNotShowWords = false
            paddingWordsSpaceKeyboardBarButtonItem.width = 5
            wordKeyboardBarButtonItem.enabled = true
            //updateTextViewCounting()
        }else{
            doNotShowWords = true
            paddingWordsSpaceKeyboardBarButtonItem.width = 0
            wordKeyboardBarButtonItem.title = ""
            wordKeyboardBarButtonItem.enabled = false
        }
        
        //updateTextViewCounting()
        textViewDidChange(self.tv)      // Call textViewDidChange manually
    }
    
    func doAfterRotate () {
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
        
        doAfterRotate()
        
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
        let keyBoardToolBar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 50))
        keyBoardToolBar.barStyle = UIBarStyle.Default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        paddingSpaceKeyboardBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        //paddingSpace.width = 5
        
        paddingWordsSpaceKeyboardBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        
        let done: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Global.Button.Done", comment: "Done"), style: UIBarButtonItemStyle.Done, target: self, action: Selector("doneButtonAction"))
        
        let infoButton: UIButton = UIButton(type: UIButtonType.InfoLight)
        infoButton.addTarget(self, action: "infoButtonAction", forControlEvents: UIControlEvents.TouchUpInside)
        let info: UIBarButtonItem = UIBarButtonItem(customView: infoButton)
        
        wordKeyboardBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: "countButtonClickedFromKeyboardBarButtonItem")
        wordKeyboardBarButtonItem.tintColor = UIColor.blackColor()
        
        paragraphKeyboardBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: "countButtonClickedFromKeyboardBarButtonItem")
        paragraphKeyboardBarButtonItem.tintColor = UIColor.blackColor()
        
        
        characterKeyboardBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: "countButtonClickedFromKeyboardBarButtonItem")
        characterKeyboardBarButtonItem.tintColor = UIColor.blackColor()
        
        
        
        let items = NSMutableArray()
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            items.addObject(wordKeyboardBarButtonItem)
            items.addObject(paddingWordsSpaceKeyboardBarButtonItem)
        }
        items.addObject(paragraphKeyboardBarButtonItem)
        items.addObject(paddingSpaceKeyboardBarButtonItem)
        items.addObject(characterKeyboardBarButtonItem)
        items.addObject(flexSpace)
        items.addObject(done)
        items.addObject(info)
        //items.addObject(info)
        
        keyBoardToolBar.items = (items.copy() as! [UIBarButtonItem])
        keyBoardToolBar.sizeToFit()
        
        self.tv.inputAccessoryView = keyBoardToolBar
        
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
        self.tv.endEditing(true)
        //self.view.endEditing(true)
    }
    
    func startEditing() {
        tv.becomeFirstResponder()
    }
    
    func clearContent() {
        endEditing()
        
        tv.text = ""
        textViewDidChange(self.tv)      // Call textViewDidChange manually
        
        //updateTextViewCounting()
        
        doAfterRotate()
    }
    
    func textViewDidChange(textView: UITextView) {
        /*if(count(Array(tv.text)) > 2){
        var lastSecChar = String(Array(tv.text)[count(tv.text)-2]) as String?
        if (lastSecChar) != nil {
        if (lastSecChar! == " ") {
        getWordCounts()
        }
        }
        }*/
        
        /*if(!tooManyWords){
            topBarCountButton.tintColor = UIColor.blackColor()
            wordKeyboard.tintColor = UIColor.blackColor()
            paragraph.tintColor = UIColor.blackColor()
            character.tintColor = UIColor.blackColor()
            
            getWordCounts()
            getParagraphCounts()
            getCharacterCounts()
        }else{
            topBarCountButton.title = NSLocalizedString("Global.Button.CountEllipsis", comment: "Count...")
            topBarCountButton.tintColor = self.view.tintColor
            
            wordKeyboard.title = ""
            paragraph.title = ""
            
            if (UIScreen.mainScreen().bounds.size.width > 750){
                wordKeyboard.title = NSLocalizedString("Global.Button.CountEllipsis", comment: "Count...")
                wordKeyboard.tintColor = self.view.tintColor
            }else{
                paragraph.title = NSLocalizedString("Global.Button.CountEllipsis", comment: "Count...")
                paragraph.tintColor = self.view.tintColor
            }
            
            
            character.title = ""
        }*/
        
        tvPlaceholderLabel.hidden = !textView.text.isEmpty
        
        updateTextViewCounting()
    }
    
    func updateTextViewCounting () {
        var wordTitle = ""
        var characterTitle = ""
        var paragraphTitle = ""
        var sentenceTitle = ""
        
        Async.background {
            wordTitle = WordCounter().getWordCountString(self.tv.text)
            characterTitle = WordCounter().getCharacterCountString(self.tv.text)
            paragraphTitle = WordCounter().getParagraphCountString(self.tv.text)
            sentenceTitle = WordCounter().getSentenceCountString(self.tv.text)
            }.main {
                self.topBarCountButton.title = wordTitle
                
                print(sentenceTitle)
                
                if (!self.doNotShowWords) {
                    self.wordKeyboardBarButtonItem.title = wordTitle
                }
                
                if (!self.doNotShowCharacter) {
                    self.characterKeyboardBarButtonItem.title = characterTitle
                }
                
                self.paragraphKeyboardBarButtonItem.title = paragraphTitle
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
        performSegueWithIdentifier("goInfo", sender: nil)
    }
    
    func countButtonClickedFromKeyboardBarButtonItem() {
        countResultButtonAction()
    }
    
    func countResultButtonAction () {
        let keyboardShowingBefore = keyboardShowing
        
        endEditing()
        
        let progressHUD = MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
        progressHUD.labelText = NSLocalizedString("Global.ProgressingHUD.Label.Counting", comment: "Counting...")
        
        var wordTitle = ""
        var characterTitle = ""
        var paragraphTitle = ""
        var sentenceTitle = ""
        
        Async.background {
            wordTitle = WordCounter().getWordCountString(self.tv.text)
            characterTitle = WordCounter().getCharacterCountString(self.tv.text)
            paragraphTitle = WordCounter().getParagraphCountString(self.tv.text)
            sentenceTitle = WordCounter().getSentenceCountString(self.tv.text)
            }.main {
                MBProgressHUD.hideAllHUDsForView(self.view.window, animated: true)
                
                let title = NSLocalizedString("Global.Alert.Counter.Title", comment: "Counter")
                let message = String.localizedStringWithFormat(NSLocalizedString("Global.Alert.Counter.Content.Word", comment: "Words: %@"), wordTitle) + "\n" + String.localizedStringWithFormat(NSLocalizedString("Global.Alert.Counter.Content.Character", comment: "Characters: %@"), characterTitle) + "\n" + String.localizedStringWithFormat(NSLocalizedString("Global.Alert.Counter.Content.Paragraph", comment: "Paragraphs: %@"), paragraphTitle) + "\n" + String.localizedStringWithFormat(NSLocalizedString("Global.Alert.Counter.Content.Sentence", comment: "Sentences: %@"), sentenceTitle) 
                
                let countingResultAlert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
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
    
    // MARK: - General func
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
        }))
        
        reviewAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Alert.PlzRate.Button.Later", comment: "Not now"), style: .Default, handler: { (action: UIAlertAction) in
            print("[提示] 用戶已按下以後再說按鈕")
            self.defaults.setBool(true, forKey: "everShowPresentReviewAgain")
            self.startEditing()
        }))
        
        reviewAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Alert.PlzRate.Button.Cancel", comment: "No, thanks!"), style: .Cancel, handler: { (action: UIAlertAction) in
            print("[提示] 用戶已按下永遠再不顯示按鈕")
            self.defaults.setBool(false, forKey: "everShowPresentReviewAgain")
            self.startEditing()
        }))
        
        presentViewController(reviewAlert, animated: true, completion: nil)
    }
}