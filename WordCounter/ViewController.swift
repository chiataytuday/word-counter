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

class ViewController: UIViewController, UITextViewDelegate, ADBannerViewDelegate {
    let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    
    var wordCounterClass = WordCounter()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let sharedData = NSUserDefaults(suiteName: "group.com.arefly.WordCounter")
    
    var countNumNow = 0
    
    var iAdHeight: CGFloat = 0.0
    
    @IBOutlet var tv: UITextView!
    
    @IBOutlet var topBarCountButton: UIBarButtonItem!
    
    var wordKeyboard: UIBarButtonItem!
    var paragraph: UIBarButtonItem!
    var character: UIBarButtonItem!
    var paddingSpace: UIBarButtonItem!
    var paddingWordsSpace: UIBarButtonItem!
    
    var doNotShowCharacter = false
    var doNotShowWords = false
    
    var keyboardShowing = false
    var iAdShowing = false
    
    var tooManyWords = false
    
    var appFirstLaunch = false
    var appJustUpdate = false
    
    //var isZhUser = false
    
    var wordSingular = NSLocalizedString("Global.Units.Short.Word.Singular", comment: "word")
    var wordPlural = NSLocalizedString("Global.Units.Short.Word.Plural", comment: "words")
    
    var charSingular = NSLocalizedString("Global.Units.Character.Singular", comment: "character")
    var charPlural = NSLocalizedString("Global.Units.Character.Plural", comment: "characters")
    
    var paraSingular = NSLocalizedString("Global.Units.Paragraph.Singular", comment: "paragraph")
    var paraPlural = NSLocalizedString("Global.Units.Paragraph.Plural", comment: "paragraphs")
    
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
        
        addToolBarToKeyboard()
        
        //self.canDisplayBannerAds = true
        
        /*var userPreferredLangs = NSLocale.preferredLanguages()
        
        for userPreferredLangFor in userPreferredLangs {
            var userPreferredLang = userPreferredLangFor as! String
            var firstTwoChars = userPreferredLang[Range(start:advance(userPreferredLang.startIndex, 0), end: advance(userPreferredLang.startIndex, 2))]
            if(firstTwoChars == "zh"){
                isZhUser = true
            }
        }
        println("[提示] isZhUser的值爲：\(isZhUser)")*/
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("[提示] View Controller 之 super.viewWillAppear() 已加載")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "doAfterRotate", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "doAfterRotate", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "endEditing", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "presentReviewAlert", name: "com.arefly.WordCounter.presentReviewAlert", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setContentFromClipBoard", name: "com.arefly.WordCounter.getContentFromClipBoard", object: nil)
        
        
        checkScreenWidthToSetButton()
        
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
        
        if( (appFirstLaunch) || (appJustUpdate) ){
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let WelcomePageVC : WelcomePageViewController = storyboard.instantiateViewControllerWithIdentifier("WelcomePageViewController") as! WelcomePageViewController
            
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
            print("[提示] appLaunchTimes的值爲"+String(defaults.integerForKey("appLaunchTimes")))
            //defaults.setInteger(8, forKey: "appLaunchTimes")
            if(defaults.integerForKey("appLaunchTimes") % 9 == 0){
                presentReviewAlert()
                defaults.setInteger(defaults.integerForKey("appLaunchTimes") + 1, forKey: "appLaunchTimes")
            }
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
    
    func checkScreenWidthToSetButton () {
        print("[提示] 準備使用 checkScreenWidthToSetButton() 函數")
        
        //let bounds = UIScreen.mainScreen().bounds
        //let bounds = UIScreen.mainScreen().applicationFrame
        let bounds = UIApplication.sharedApplication().keyWindow?.bounds
        let width = bounds!.size.width
        let height = bounds!.size.height
        print("[提示] 屏幕高度：\(height)、屏幕寬度：\(width)")
        
        if(!tooManyWords){
            if (width < 330){
                doNotShowCharacter = true
                paddingWordsSpace.width = 0
                character.title = ""
                character.enabled = false
            }else{
                doNotShowCharacter = false
                paddingSpace.width = 5
                character.enabled = true
                changeCharacterCounts()
            }
            //changeWordCounts()
            //changeParagraphCounts()
            
            if (width > 750){
                doNotShowWords = false
                paddingWordsSpace.width = 5
                wordKeyboard.enabled = true
                changeWordCounts()
            }else{
                doNotShowWords = true
                paddingWordsSpace.width = 0
                wordKeyboard.title = ""
                wordKeyboard.enabled = false
            }
        }
    }
    
    func keyboardShow(n: NSNotification) {
        keyboardShowing = true
        
        setTextViewSize(n)
        
        doAfterRotate()
    }
    
    func setTextViewSize (n: NSNotification) {
        if (keyboardShowing) {
            let d = n.userInfo!
            var r = (d[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            r = self.tv.convertRect(r, fromView:nil)
            self.tv.contentInset.bottom = r.size.height
            self.tv.scrollIndicatorInsets.bottom = r.size.height
        }
        
        //println(UIApplication.sharedApplication().statusBarOrientation.isPortrait)
        
        /*
        Removed due to the top of TV change to TopGuide which is the nav bar
        
        var topHeight: CGFloat = self.navigationController!.navigationBar.frame.size.height
        //if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
        if ( (UIApplication.sharedApplication().statusBarOrientation.isPortrait) || (UIDevice.currentDevice().userInterfaceIdiom == .Pad) ) {
            topHeight += UIApplication.sharedApplication().statusBarFrame.size.height
        }
        
        self.tv.contentInset.top = topHeight
        self.tv.scrollIndicatorInsets.top = topHeight*/
        
        self.tv.contentInset.top = 0
        self.tv.scrollIndicatorInsets.top = 0
    }
    
    func keyboardHide(n: NSNotification) {
        let selectedRangeBeforeHide = tv.selectedRange
        
        keyboardShowing = false
        /*self.tv.contentInset = UIEdgeInsetsZero
        self.tv.scrollIndicatorInsets = UIEdgeInsetsZero*/
        if( (iAdShowing) && (iAdHeight > 0.0) ){
            self.tv.contentInset.bottom = iAdHeight
            self.tv.scrollIndicatorInsets.bottom = iAdHeight
        //}else if (self.tv.contentInset.bottom != 0){
        }else{
            self.tv.contentInset.bottom = 0
            self.tv.scrollIndicatorInsets.bottom = 0
        }
        
        tv.scrollRangeToVisible(selectedRangeBeforeHide)
        tv.selectedRange = selectedRangeBeforeHide
    }
    
    func addToolBarToKeyboard(){
        let keyBoardToolBar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 50))
        keyBoardToolBar.barStyle = UIBarStyle.Default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        paddingSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        //paddingSpace.width = 5
        
        paddingWordsSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        
        let done: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Global.Button.Done", comment: "Done"), style: UIBarButtonItemStyle.Done, target: self, action: Selector("doneButtonAction"))
        
        let infoButton: UIButton = UIButton(type: UIButtonType.InfoLight)
        infoButton.addTarget(self, action: "infoButtonAction", forControlEvents: UIControlEvents.TouchUpInside)
        let info: UIBarButtonItem = UIBarButtonItem(customView: infoButton)
        
        wordKeyboard = UIBarButtonItem(title: String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text.Word.Zero", comment: "0 %@<-words"), wordPlural), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("countResultButtonAction"))
        wordKeyboard.tintColor = UIColor.blackColor()
        
        paragraph = UIBarButtonItem(title: String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text.Paragraph.Zero", comment: "0 %@<-paragraphs"), paraPlural), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("countResultButtonAction"))
        paragraph.tintColor = UIColor.blackColor()
        
        character = UIBarButtonItem(title: String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text.Character.Zero", comment: "0 %@<-characters"), charPlural), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("countResultButtonAction"))
        character.tintColor = UIColor.blackColor()
        
        
        
        let items = NSMutableArray()
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            items.addObject(wordKeyboard)
            items.addObject(paddingWordsSpace)
        }
        items.addObject(paragraph)
        items.addObject(paddingSpace)
        items.addObject(character)
        items.addObject(flexSpace)
        items.addObject(done)
        items.addObject(info)
        //items.addObject(info)
        
        keyBoardToolBar.items = (items.copy() as! [UIBarButtonItem])
        keyBoardToolBar.sizeToFit()
        
        self.tv.inputAccessoryView = keyBoardToolBar
        
    }
    
    func endEditing() {
        self.tv.endEditing(true)
    }
    
    @IBAction func clearButtonClicked(sender: AnyObject) {
        
        self.tv.endEditing(true)
        
        let clearContentAlert = UIAlertController(
            title: NSLocalizedString("Global.Alert.BeforeClear.Title", comment: "Clear all content?"),
            message: NSLocalizedString("Global.Alert.BeforeClear.Content", comment: "WARNING: This action is irreversible!"),
            preferredStyle: UIAlertControllerStyle.Alert)
        
        clearContentAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Yes", comment: "Yes"), style: .Default, handler: { (action: UIAlertAction) in
            print("[提示] 用戶已按下確定清空按鈕")
            self.clearContent()
        }))
        
        clearContentAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Close", comment: "Close"), style: .Cancel, handler: { (action: UIAlertAction) in
            print("[提示] 用戶已按下取消清空按鈕")
        }))
        
        presentViewController(clearContentAlert, animated: true, completion: nil)
    }
    
    func clearContent() {
        self.view.endEditing(true)
        tv.text = ""
        tooManyWords = false
        
        topBarCountButton.title = String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text.Word.Zero", comment: "0 %@<-words"), wordPlural)
        topBarCountButton.tintColor = UIColor.blackColor()
        
        wordKeyboard.title = String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text.Word.Zero", comment: "0 %@<-words"), wordPlural)
        wordKeyboard.tintColor = UIColor.blackColor()
        
        paragraph.title = String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text.Paragraph.Zero", comment: "0 %@<-paragraphs"), paraPlural)
        paragraph.tintColor = UIColor.blackColor()
        
        character.title = String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text.Character.Zero", comment: "0 %@<-characters"), charPlural)
        character.tintColor = UIColor.blackColor()
        
        checkScreenWidthToSetButton()
        
        /*println("[提示] 準備發送清空按鈕統計數據")
        var tracker = GAI.sharedInstance().defaultTracker
        var event = GAIDictionaryBuilder.createEventWithCategory("Action", action: "Clear Button Clicked", label: nil, value: nil)
        tracker.send(event.build() as [NSObject : AnyObject])*/
    }
    
    func textViewDidChange(textView: UITextView) {
        /*if(count(Array(tv.text)) > 2){
        var lastSecChar = String(Array(tv.text)[count(tv.text)-2]) as String?
        if (lastSecChar) != nil {
        if (lastSecChar! == " ") {
        changeWordCounts()
        }
        }
        }*/
        if(!tooManyWords){
            topBarCountButton.tintColor = UIColor.blackColor()
            wordKeyboard.tintColor = UIColor.blackColor()
            paragraph.tintColor = UIColor.blackColor()
            character.tintColor = UIColor.blackColor()
            
            changeWordCounts()
            changeParagraphCounts()
            changeCharacterCounts()
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
        }
    }
    
    func changeCharacterCounts () {
        if (!doNotShowCharacter) {
            let count = wordCounterClass.characterCount(tv.text)
            
            if(count >= 1500){
                tooManyWords = true
            }
            
            let words = (count == 1) ? charSingular : charPlural
            let title = String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text.Character.NonZero", comment: "%1$@ %2$@"), String(count), words)
            
            character.title = title
        }
    }
    
    func changeParagraphCounts () {
        let count = wordCounterClass.paragraphCount(tv.text)
        
        let words = (count == 1) ? paraSingular : paraPlural
        let title = String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text.Paragraph.NonZero", comment: "%1$@ %2$@"), String(count), words)
        
        paragraph.title = title
    }
    
    func changeWordCounts () {
        let count = wordCounterClass.wordCount(tv.text)
        
        let words = (count == 1) ? wordSingular : wordPlural
        let title = String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text.Word.NonZero", comment: "%1$@ %2$@"), String(count), words)
        
        topBarCountButton.title = title
        
        if (!doNotShowWords) {
            wordKeyboard.title = title
        }
    }
    

    func doAfterRotate () {
        if(iAdShowing){
            iAdHeight = appDelegate.bannerView.frame.size.height
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
    
    func infoButtonAction () {
        performSegueWithIdentifier("goInfo", sender: nil)
    }
    
    func countResultButtonAction () {
        let wordCounts = wordCounterClass.wordCount(tv.text)
        let wordWords = (wordCounts == 1) ? wordSingular : wordPlural
        let wordTitle = String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text.Word.NonZero", comment: "%1$@ %2$@"), String(wordCounts), wordWords)
        
        let charCount = wordCounterClass.characterCount(tv.text)
        let charWords = (charCount == 1) ? charSingular : charPlural
        let charTitle = String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text.Character.NonZero", comment: "%1$@ %2$@"), String(charCount), charWords)

        let paraCount = wordCounterClass.paragraphCount(tv.text)
        let paraWords = (paraCount == 1) ? paraSingular : paraPlural
        let paraTitle = String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text.Paragraph.NonZero", comment: "%1$@ %2$@"), String(paraCount), paraWords)

        let title = NSLocalizedString("Global.Alert.Counter.Title", comment: "Counter")
        let message = String.localizedStringWithFormat(NSLocalizedString("Global.Alert.Counter.Content.Word", comment: "Words: %@\n"), wordTitle) + String.localizedStringWithFormat(NSLocalizedString("Global.Alert.Counter.Content.Character", comment: "Characters: %@\n"), charTitle) + String.localizedStringWithFormat(NSLocalizedString("Global.Alert.Counter.Content.Paragraph", comment: "Paragraphs: %@"), paraTitle)
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: NSLocalizedString("Global.Button.Done", comment: "Done"), style: .Cancel) { _ in
            // DO NOTHING
        }
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
        
        /*println("[提示] 準備發送統計按鈕統計數據")
        var tracker = GAI.sharedInstance().defaultTracker
        var event = GAIDictionaryBuilder.createEventWithCategory("Action", action: "Count Button Clicked", label: nil, value: nil)
        tracker.send(event.build() as [NSObject : AnyObject])*/
    }
    
    
    @IBAction func topBarCountingButtonClicked(sender: AnyObject) {
        countResultButtonAction()
    }
    
    /*
    func pasteButtonAction() {
    if ((UIPasteboard.generalPasteboard().string) != nil) {
    tv.text = tv.text + UIPasteboard.generalPasteboard().string! as String!
    changeWordCounts()
    tv.scrollRangeToVisible(NSMakeRange(count(tv.text), 0))
    tv.selectedRange = NSMakeRange(count(tv.text), 0)
    }
    }*/
    
    func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    func setContentFromClipBoard() {
        print("[提示] -- 已開始使用 setContentFromClipBoard() 函數 --")
        
        tv.text = "WAHAHA"
        
        if let clipBoard = UIPasteboard.generalPasteboard().string {
            print("[提示] 已獲取用戶剪貼簿內容：\(clipBoard)")
            tv.text = clipBoard
            changeCharacterCounts()
            changeWordCounts()
            changeParagraphCounts()
        }
    }
    
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
            
            iAdHeight = appDelegate.bannerView.frame.size.height
            
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
            preferredStyle: UIAlertControllerStyle.Alert)
        
        reviewAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Alert.PlzRate.Button.Yes", comment: "Sure!"), style: .Default, handler: { (action: UIAlertAction) in
            print("[提示] 用戶已按下發表評論按鈕")
            self.defaults.setBool(false, forKey: "everShowPresentReviewAgain")
            UIApplication.sharedApplication().openURL(BasicConfig().appStoreReviewUrl!)
        }))
        
        reviewAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Alert.PlzRate.Button.Later", comment: "Not now"), style: .Default, handler: { (action: UIAlertAction) in
            print("[提示] 用戶已按下以後再說按鈕")
            self.defaults.setBool(true, forKey: "everShowPresentReviewAgain")
        }))
        
        reviewAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Alert.PlzRate.Button.Cancel", comment: "No, thanks!"), style: .Cancel, handler: { (action: UIAlertAction) in
            print("[提示] 用戶已按下永遠再不顯示按鈕")
            self.defaults.setBool(false, forKey: "everShowPresentReviewAgain")
        }))
        
        presentViewController(reviewAlert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.tv.endEditing(true)
    }
}