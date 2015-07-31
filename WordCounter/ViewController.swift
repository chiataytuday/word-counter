//
//  ViewController.swift
//  WordCounter
//
//  Created by Arefly on 5/7/2015.
//  Copyright (c) 2015年 Arefly. All rights reserved.
//

import UIKit
import Foundation

extension String {
    var containsChineseCharacters: Bool {
        return self.rangeOfString("\\p{Han}", options: .RegularExpressionSearch) != nil
    }
}

class ViewController: UIViewController, UITextViewDelegate {
    let alert = UIAlertView()
    
    var countNumNow = 0
    
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
    
    //var isZhUser = false
    
    var wordSingular = NSLocalizedString("WORD_SINGULAR", comment: "word")
    var wordPlural = NSLocalizedString("WORD_PLURAL", comment: "words")
    
    var charSingular = NSLocalizedString("CHAR_SINGULAR", comment: "character")
    var charPlural = NSLocalizedString("CHAR_PLURAL", comment: "characters")
    
    var paraSingular = NSLocalizedString("PARA_SINGULAR", comment: "paragraph")
    var paraPlural = NSLocalizedString("PARA_PLURAL", comment: "paragraphs")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("[提示] View Controller 之 super.viewDidLoad() 已加載")
        
        addDoneButtonOnKeyboard()
        checkScreenWidthToSetButton()
        
        self.tv.delegate = self
        
        /*var userPreferredLangs = NSLocale.preferredLanguages()
        
        for userPreferredLangFor in userPreferredLangs {
            var userPreferredLang = userPreferredLangFor as! String
            var firstTwoChars = userPreferredLang[Range(start:advance(userPreferredLang.startIndex, 0), end: advance(userPreferredLang.startIndex, 2))]
            if(firstTwoChars == "zh"){
                isZhUser = true
            }
        }
        println("[提示] isZhUser的值爲：\(isZhUser)")*/
        
        
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "doAfterRotate", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    /*override func shouldAutorotate() -> Bool {
    return !self.keyboardShowing
    }*/
    
    func checkScreenWidthToSetButton () {
        var bounds = UIScreen.mainScreen().bounds
        var width = bounds.size.width
        //var height = bounds.size.height
        //println(width)
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
    
    func keyboardShow(n:NSNotification) {
        self.keyboardShowing = true
        
        setTextViewSize(n)
    }
    
    func setTextViewSize (n:NSNotification) {
        if (keyboardShowing) {
            let d = n.userInfo!
            var r = (d[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            r = self.tv.convertRect(r, fromView:nil)
            self.tv.contentInset.bottom = r.size.height
            self.tv.scrollIndicatorInsets.bottom = r.size.height
        }
        
        //println(UIApplication.sharedApplication().statusBarOrientation.isPortrait)
        
        var topHeight: CGFloat = self.navigationController!.navigationBar.frame.size.height
        //if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
        if ( (UIApplication.sharedApplication().statusBarOrientation.isPortrait) || (UIDevice.currentDevice().userInterfaceIdiom == .Pad) ) {
            topHeight += UIApplication.sharedApplication().statusBarFrame.size.height
        }
        
        self.tv.contentInset.top = topHeight
        self.tv.scrollIndicatorInsets.top = topHeight
    }
    
    func keyboardHide(n:NSNotification) {
        
        var selectedRangeBeforeHide = tv.selectedRange
        
        self.keyboardShowing = false
        /*self.tv.contentInset = UIEdgeInsetsZero
        self.tv.scrollIndicatorInsets = UIEdgeInsetsZero*/
        self.tv.contentInset.bottom = 0
        self.tv.scrollIndicatorInsets.bottom = 0
        
        tv.scrollRangeToVisible(selectedRangeBeforeHide)
        tv.selectedRange = selectedRangeBeforeHide
    }
    
    func addDoneButtonOnKeyboard(){
        var keyBoardToolBar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 50))
        keyBoardToolBar.barStyle = UIBarStyle.Default
        
        var flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        paddingSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        //paddingSpace.width = 5
        
        paddingWordsSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        
        var done: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("DONE_BUTTON", comment: "Done"), style: UIBarButtonItemStyle.Done, target: self, action: Selector("doneButtonAction"))
        
        var infoButton: UIButton = UIButton.buttonWithType(UIButtonType.InfoLight) as! UIButton
        infoButton.addTarget(self, action: "infoButtonAction", forControlEvents: UIControlEvents.TouchUpInside)
        var info: UIBarButtonItem = UIBarButtonItem(customView: infoButton)
        
        wordKeyboard = UIBarButtonItem(title: String.localizedStringWithFormat(NSLocalizedString("ZERO_WORDS", comment: "0 %@<-words"), wordPlural), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("countResultButtonAction"))
        wordKeyboard.tintColor = UIColor.blackColor()
        
        paragraph = UIBarButtonItem(title: String.localizedStringWithFormat(NSLocalizedString("ZERO_PARAS", comment: "0 %@<-paragraphs"), paraPlural), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("countResultButtonAction"))
        paragraph.tintColor = UIColor.blackColor()
        
        character = UIBarButtonItem(title: String.localizedStringWithFormat(NSLocalizedString("ZERO_CHARS", comment: "0 %@<-characters"), charPlural), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("countResultButtonAction"))
        character.tintColor = UIColor.blackColor()
        
        
        
        var items = NSMutableArray()
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
        
        keyBoardToolBar.items = items as [AnyObject]
        keyBoardToolBar.sizeToFit()
        
        self.tv.inputAccessoryView = keyBoardToolBar
        
    }
    
    
    @IBAction func clearButtonClicked(sender: AnyObject) {
        self.view.endEditing(true)
        tv.text = ""
        topBarCountButton.title = String.localizedStringWithFormat(NSLocalizedString("ZERO_WORDS", comment: "0 %@<-words"), wordPlural)
        wordKeyboard.title = String.localizedStringWithFormat(NSLocalizedString("ZERO_WORDS", comment: "0 %@<-words"), wordPlural)
        paragraph.title = String.localizedStringWithFormat(NSLocalizedString("ZERO_PARAS", comment: "0 %@<-paragraphs"), paraPlural)
        character.title = String.localizedStringWithFormat(NSLocalizedString("ZERO_CHARS", comment: "0 %@<-characters"), charPlural)
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
        changeWordCounts()
        changeParagraphCounts()
        changeCharacterCounts()
    }
    
    func changeCharacterCounts () {
        if (!doNotShowCharacter) {
            var count = characterCount(tv.text)
            
            var words = (count == 1) ? charSingular : charPlural
            var title = String.localizedStringWithFormat(NSLocalizedString("MANY_CHARS", comment: "%1$@ %2$@"), String(count), words)
            
            character.title = title
        }
    }
    
    func changeParagraphCounts () {
        var count = paragraphCount(tv.text)
        
        var words = (count == 1) ? paraSingular : paraPlural
        var title = String.localizedStringWithFormat(NSLocalizedString("MANY_PARAS", comment: "%1$@ %2$@"), String(count), words)
        
        paragraph.title = title
    }
    
    func changeWordCounts () {
        var count = wordCount(tv.text)
        
        var words = (count == 1) ? wordSingular : wordPlural
        var title = String.localizedStringWithFormat(NSLocalizedString("MANY_WORDS", comment: "%1$@ %2$@"), String(count), words)
        
        topBarCountButton.title = title
        
        if (!doNotShowWords) {
            wordKeyboard.title = title
        }
    }
    
    func characterCount(s: String) -> Int {
        var characterCounts = 0
        var modifiedCharacter = Array(s).filter({
            let s = String($0) as String?
            if !(s != nil) { return false }
            if count(s!) < 1 { return false }
            if (s == "\n") { return false }
            if s! == " " { return false }
            return true
        })
        characterCounts = count(modifiedCharacter)
        return characterCounts
    }
    
    func paragraphCount(s: String) -> Int {
        var paragraphCounts = 0
        var lines = s.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
        var modifiedLines = lines.filter({
            let s = $0 as String?
            if !(s != nil) { return false }
            if count(s!) < 1 { return false }
            return true
        })
        paragraphCounts = count(modifiedLines)
        return paragraphCounts
    }
    
    
    func wordCount(s: String) -> Int {
        /*
        var counts = 0
        var lines = s.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
        //var words = s.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        for line in lines {
        var words = line.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        for word in words {
        if !(word.isEmpty){
        if(word.containsChineseCharacters){
        var stringlength = count(word)
        var ierror: NSError?
        var chineseRegex: NSRegularExpression = NSRegularExpression(pattern: "\\p{Han}", options: NSRegularExpressionOptions.CaseInsensitive, error: &ierror)!
        /*var replacedString = chineseRegex.stringByReplacingMatchesInString(word, options: nil, range: NSMakeRange(0, stringlength), withTemplate: "|CHI|")
        
        
        var separatedArray: Array = replacedString.componentsSeparatedByString("|")
        
        
        for separatedString in separatedArray {
        if !(separatedString.isEmpty){
        counts += 1
        }
        }*/
        
        //var results = chineseRegex.matchesInString(word, options: nil, range: NSMakeRange(0, count(word))) as! Array<NSTextCheckingResult>
        
        var results = matchesForRegexInText("\\p{Han}", text: word)
        
        counts += count(results)
        }else{
        counts += 1
        }
        }
        }
        }
        return counts*/
        
        /*var counts = 0
        var lines = s.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
        for line in lines {
        var words = line.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        var modifiedWords = words.filter({
        let s = $0 as String?
        if !(s != nil) { return false }
        if count(s!) < 1 { return false }
        if(s!.containsChineseCharacters){
        var stringlength = count(s!)
        var ierror: NSError?
        var chineseRegex: NSRegularExpression = NSRegularExpression(pattern: "\\p{Han}", options: NSRegularExpressionOptions.CaseInsensitive, error: &ierror)!
        var replacedString = chineseRegex.stringByReplacingMatchesInString(s!, options: nil, range: NSMakeRange(0, stringlength), withTemplate: "|CHI|")
        
        var separatedArray: Array = replacedString.componentsSeparatedByString("|")
        
        
        for separatedString in separatedArray {
        if !(separatedString.isEmpty){
        counts += 1
        }
        }
        return false
        }
        return true
        })
        
        counts += count(modifiedWords)
        }
        return counts*/
        
        var counts = 0
        var lines = s.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
        let joinedString = " ".join(lines)
        var words = joinedString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        var modifiedWords = words.filter({
            let s = $0 as String?
            if !(s != nil) { return false }
            if count(s!) < 1 { return false }
            //if(self.isZhUser){
            if(s!.containsChineseCharacters){
                var results = self.matchesForRegexInText("\\p{Han}", text: s!)
                var sArray: Array = Array(s!)
                if(String(sArray[0]) != results[0]){
                    counts += 1
                }
                //println(sArray[count(sArray)-1])
                //println(results[count(results)-1])
                if(String(sArray[count(sArray)-1]) != results[count(results)-1]){
                    counts += 1
                }
                counts += count(results)
                return false
            }
            //}
            return true
        })
        
        counts += count(modifiedWords)
        
        return counts
    }
    
    func matchesForRegexInText(regex: String!, text: String!) -> [String] {
        let regex = NSRegularExpression(pattern: regex,
            options: nil, error: nil)!
        let nsString = text as NSString
        let results = regex.matchesInString(text, options: nil, range: NSMakeRange(0, nsString.length)) as! [NSTextCheckingResult]
        return map(results) { nsString.substringWithRange($0.range)}
    }
    
    
    func doAfterRotate () {
        checkScreenWidthToSetButton()
    }
    
    func infoButtonAction () {
        performSegueWithIdentifier("goInfo", sender: nil)
    }
    
    func countResultButtonAction () {
        var wordCounts = wordCount(tv.text)
        var wordWords = (wordCounts == 1) ? wordSingular : wordPlural
        var wordTitle = String.localizedStringWithFormat(NSLocalizedString("MANY_WORDS", comment: "%1$@ %2$@"), String(wordCounts), wordWords)
        
        var charCount = characterCount(tv.text)
        var charWords = (charCount == 1) ? charSingular : charPlural
        var charTitle = String.localizedStringWithFormat(NSLocalizedString("MANY_CHARS", comment: "%1$@ %2$@"), String(charCount), charWords)

        var paraCount = paragraphCount(tv.text)
        var paraWords = (paraCount == 1) ? paraSingular : paraPlural
        var paraTitle = String.localizedStringWithFormat(NSLocalizedString("MANY_PARAS", comment: "%1$@ %2$@"), String(paraCount), paraWords)
    
        alert.title = NSLocalizedString("COUNTER_ALERT_TITLE", comment: "Counter")
        alert.message = String.localizedStringWithFormat(NSLocalizedString("WORDS_ALERT_CONTENT", comment: "Words: %@\n"), wordTitle) + String.localizedStringWithFormat(NSLocalizedString("CHARS_ALERT_CONTENT", comment: "Characters: %@\n"), charTitle) + String.localizedStringWithFormat(NSLocalizedString("PARAS_ALERT_CONTENT", comment: "Paragraphs: %@"), paraTitle)
        alert.addButtonWithTitle(NSLocalizedString("OK_BUTTON", comment: "OK!"))
        alert.show()
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
    
}