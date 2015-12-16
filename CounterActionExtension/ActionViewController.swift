//
//  ActionViewController.swift
//  CounterActionExtension
//
//  Created by Jason Ho on 15/12/2015.
//  Copyright © 2015 Arefly. All rights reserved.
//

import UIKit
import Foundation
import MobileCoreServices
import Async
import MBProgressHUD

class ActionViewController: UIViewController {

    @IBOutlet weak var contentTextView: UITextView!
    var convertedString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[提示] Action View Controller 之 super.viewDidLoad() 已加載")
        
        let textItem = self.extensionContext!.inputItems[0] as! NSExtensionItem
        
        let textItemProvider = textItem.attachments![0]
            as! NSItemProvider
        
        if textItemProvider.hasItemConformingToTypeIdentifier(kUTTypeText as NSString as String) {
            textItemProvider.loadItemForTypeIdentifier(kUTTypeText as String, options: nil, completionHandler: {(string, error) in
                self.convertedString = string as? String
                
                if self.convertedString != nil {
                    //self.convertedString = self.convertedString!.uppercaseString
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        let text = self.convertedString!
                        
                        self.contentTextView.text = text
                        
                        self.showCountResult(text)
                    }
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showCountResult (text: String) {
        let progressHUD = MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
        progressHUD.labelText = NSLocalizedString("Global.ProgressingHUD.Label.Counting", comment: "Counting...")
        
        var wordTitle = ""
        var characterTitle = ""
        var paragraphTitle = ""
        var sentenceTitle = ""
        
        Async.background {
            wordTitle = WordCounter().getWordCountString(text)
            characterTitle = WordCounter().getCharacterCountString(text)
            paragraphTitle = WordCounter().getParagraphCountString(text)
            sentenceTitle = WordCounter().getSentenceCountString(text)
            }.main {
                MBProgressHUD.hideAllHUDsForView(self.view.window, animated: true)
                
                let title = NSLocalizedString("Global.Alert.Counter.Title", comment: "Counter")
                let message = String.localizedStringWithFormat(NSLocalizedString("Global.Alert.Counter.Content.Word", comment: "Words: %@"), wordTitle) + "\n" + String.localizedStringWithFormat(NSLocalizedString("Global.Alert.Counter.Content.Character", comment: "Characters: %@"), characterTitle) + "\n" + String.localizedStringWithFormat(NSLocalizedString("Global.Alert.Counter.Content.Paragraph", comment: "Paragraphs: %@"), paragraphTitle) + "\n" + String.localizedStringWithFormat(NSLocalizedString("Global.Alert.Counter.Content.Sentence", comment: "Sentences: %@"), sentenceTitle)
                
                let countingResultAlert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                countingResultAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Done", comment: "Done"), style: .Cancel, handler: { (action: UIAlertAction) in
                    print("[提示] 用戶已按下確定按鈕")
                }))
                self.presentViewController(countingResultAlert, animated: true, completion: nil)
        }
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        //self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
        
        let returnProvider = NSItemProvider(item: convertedString, typeIdentifier: kUTTypeText as String)
        
        let returnItem = NSExtensionItem()
        
        returnItem.attachments = [returnProvider]
        self.extensionContext!.completeRequestReturningItems([returnItem], completionHandler: nil)

    }

}
