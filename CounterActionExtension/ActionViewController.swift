//
//  ActionViewController.swift
//  CounterActionExtension
//
//  Created by Jason Ho on 15/12/2015.
//  Copyright © 2015 Arefly. All rights reserved.
//

import UIKit
import MobileCoreServices

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
                        self.contentTextView.text = self.convertedString!
                    }
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
