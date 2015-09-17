//
//  TodayViewController.swift
//  WordCounterTodayWidget
//
//  Created by Arefly on 7/8/2015.
//  Copyright (c) 2015年 Arefly. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, UITextViewDelegate, NCWidgetProviding {
    
    var sharedData = NSUserDefaults(suiteName: "group.com.arefly.WordCounter")
        
    @IBOutlet var textView: UITextView!
    @IBOutlet var wordsCountLabel: UILabel!
    @IBOutlet var parasCountLabel: UILabel!
    @IBOutlet var charsCountLabel: UILabel!
    
    var wordCounterClass = WordCounter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[提示] Today View Controller 之 super.viewDidLoad() 已加載")
        
        //self.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        //textView.setTranslatesAutoresizingMaskIntoConstraints(false)
        //self.view.sizeToFit()
        //textView.sizeToFit()
        
        //textView.selectable = false
        textView.delegate = self
        //textView.userInteractionEnabled = true
        //textView.becomeFirstResponder()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "pressedOnce")
        self.view.addGestureRecognizer(tapGesture)
        
        var wordSingular = NSLocalizedString("WORD_SINGULAR_SHORT", comment: "word")
        var wordPlural = NSLocalizedString("WORD_PLURAL_SHORT", comment: "words")
        
        var charSingular = NSLocalizedString("CHAR_SINGULAR_SHORT", comment: "char.")
        var charPlural = NSLocalizedString("CHAR_PLURAL_SHORT", comment: "chars.")
        
        var paraSingular = NSLocalizedString("PARA_SINGULAR_SHORT", comment: "para.")
        var paraPlural = NSLocalizedString("PARA_PLURAL_SHORT", comment: "paras.")
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            print("提示：用戶正使用iPad！")
            wordSingular = NSLocalizedString("WORD_SINGULAR", comment: "word")
            wordPlural = NSLocalizedString("WORD_PLURAL", comment: "words")
            
            charSingular = NSLocalizedString("CHAR_SINGULAR", comment: "character")
            charPlural = NSLocalizedString("CHAR_PLURAL", comment: "characters")
            
            paraSingular = NSLocalizedString("PARA_SINGULAR", comment: "paragraph")
            paraPlural = NSLocalizedString("PARA_PLURAL", comment: "paragraphs")
        }
        
        //var clipBoard = UIPasteboard.generalPasteboard().string
        
        /*
        textView.text = "XDD"
        textView.textColor = UIColor.whiteColor()
        //textView.font = UIFont(name: textView.font.fontName, size: 14)*/
        
        if let clipBoard = UIPasteboard.generalPasteboard().string {
            print("[提示] 已獲取用戶剪貼簿內容：\(clipBoard)")
            
            textView.text = clipBoard
            
            let wordCounts = wordCounterClass.wordCount(textView.text)
            let wordWords = (wordCounts == 1) ? wordSingular : wordPlural
            let wordTitle = String.localizedStringWithFormat(NSLocalizedString("MANY_WORDS", comment: "%1$@ %2$@"), String(wordCounts), wordWords)
            
            let charCount = wordCounterClass.characterCount(textView.text)
            let charWords = (charCount == 1) ? charSingular : charPlural
            let charTitle = String.localizedStringWithFormat(NSLocalizedString("MANY_CHARS", comment: "%1$@ %2$@"), String(charCount), charWords)
            
            let paraCount = wordCounterClass.paragraphCount(textView.text)
            let paraWords = (paraCount == 1) ? paraSingular : paraPlural
            let paraTitle = String.localizedStringWithFormat(NSLocalizedString("MANY_PARAS", comment: "%1$@ %2$@"), String(paraCount), paraWords)
            
            wordsCountLabel.text = wordTitle
            parasCountLabel.text = paraTitle
            charsCountLabel.text = charTitle
        }else{
            print("[提示] 用戶剪貼簿內並未任何內容")
            
            textView.text = NSLocalizedString("NOTHING_IN_CLIPBOARD", comment: "Nothing in your clipboard!")
            
            wordsCountLabel.text = String.localizedStringWithFormat(NSLocalizedString("ZERO_WORDS", comment: "0 %@<-words"), wordPlural)
            parasCountLabel.text = String.localizedStringWithFormat(NSLocalizedString("ZERO_PARAS", comment: "0 %@<-paragraphs"), paraPlural)
            charsCountLabel.text = String.localizedStringWithFormat(NSLocalizedString("ZERO_CHARS", comment: "0 %@<-characters"), charPlural)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("[提示] Today View Controller 之 super.viewDidAppear() 已加載")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("[提示] Today View Controller 之 super.viewWillAppear() 已加載")
        
    }
    
    /*override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            
        }
        println("TOUCH LAHAHAHAHAH")
        super.touchesBegan(touches , withEvent:event)
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        //return UIEdgeInsetsMake(5, 0, 5, -10)
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
    
}
