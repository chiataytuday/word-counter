//
//  TodayViewController.swift
//  WordCounterTodayWidget
//
//  Created by Arefly on 7/8/2015.
//  Copyright (c) 2015 Arefly. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, UITextViewDelegate, NCWidgetProviding {
    
    var sharedData = NSUserDefaults(suiteName: "group.com.arefly.WordCounter")
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var wordsCountLabel: UILabel!
    @IBOutlet var parasCountLabel: UILabel!
    @IBOutlet var charsCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[提示] Today View Controller 之 super.viewDidLoad() 已加載")
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.userInteractionEnabled = true
        
        textView.delegate = self
        textView.userInteractionEnabled = true
        
        textView.selectable = true  //BUG IN APPLE SIDE
        textView.textColor = UIColor.whiteColor()
        textView.selectable = false

        
        let tapGesture = UITapGestureRecognizer(target: self, action: "pressedOnce")
        self.view.addGestureRecognizer(tapGesture)
        
        var wordSingular = NSLocalizedString("Global.Units.Short.Word.Singular", comment: "word")
        var wordPlural = NSLocalizedString("Global.Units.Short.Word.Plural", comment: "words")
        
        var charSingular = NSLocalizedString("Global.Units.Short.Character.Singular", comment: "char.")
        var charPlural = NSLocalizedString("Global.Units.Short.Character.Plural", comment: "chars.")
        
        var paraSingular = NSLocalizedString("Global.Units.Short.Paragraph.Singular", comment: "para.")
        var paraPlural = NSLocalizedString("Global.Units.Short.Paragraph.Plural", comment: "paras.")
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            print("提示：用戶正使用iPad！")
            wordSingular = NSLocalizedString("Global.Units.Short.Word.Singular", comment: "word")
            wordPlural = NSLocalizedString("Global.Units.Short.Word.Plural", comment: "words")
            
            charSingular = NSLocalizedString("Global.Units.Character.Singular", comment: "character")
            charPlural = NSLocalizedString("Global.Units.Character.Plural", comment: "characters")
            
            paraSingular = NSLocalizedString("Global.Units.Paragraph.Singular", comment: "paragraph")
            paraPlural = NSLocalizedString("Global.Units.Paragraph.Plural", comment: "paragraphs")
        }
        
        
        var wordCounts = 0
        var charCount = 0
        var paraCount = 0
        
        if let clipBoard = UIPasteboard.generalPasteboard().string {
            print("[提示] 已獲取用戶剪貼簿內容：\(clipBoard)")
            textView.text = clipBoard
            
            wordCounts = WordCounter().wordCount(textView.text)
            charCount = WordCounter().characterCount(textView.text)
            paraCount = WordCounter().paragraphCount(textView.text)
        }else{
            print("[提示] 用戶剪貼簿內並未任何內容")
            textView.text = NSLocalizedString("Global.Text.NothingOnClipboard", comment: "Nothing in your clipboard!")
        }
        
        let wordWords = (wordCounts == 1) ? wordSingular : wordPlural
        let wordTitle = String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text.Word", comment: "%1$@ %2$@"), String(wordCounts), wordWords)
        
        let charWords = (charCount == 1) ? charSingular : charPlural
        let charTitle = String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text.Character", comment: "%1$@ %2$@"), String(charCount), charWords)
        
        let paraWords = (paraCount == 1) ? paraSingular : paraPlural
        let paraTitle = String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text.Paragraph", comment: "%1$@ %2$@"), String(paraCount), paraWords)
        
        wordsCountLabel.text = wordTitle
        parasCountLabel.text = paraTitle
        charsCountLabel.text = charTitle
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("[提示] Today View Controller 之 super.viewDidAppear() 已加載")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("[提示] Today View Controller 之 super.viewWillAppear() 已加載")
        
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets{
        //return UIEdgeInsetsZero
        return UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
    func pressedOnce() {
        print("[提示] 用戶已按下任意位置！")
        if let clipBoard = UIPasteboard.generalPasteboard().string {
            print("[提示] 已獲取用戶剪貼簿內容：\(clipBoard)")
            self.extensionContext?.openURL(NSURL(string: "count://fromClipBoard")!, completionHandler:{(success: Bool) -> Void in
                print("[提示] 已開啓App")
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}