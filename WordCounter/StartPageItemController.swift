//
//  StartPageItemController.swift
//  Catnap
//
//  Created by Arefly on 3/7/2015.
//  Copyright (c) 2015年 Arefly. All rights reserved.
//

import Foundation
import UIKit

class StartPageItemController: UIViewController {
    
    @IBOutlet var contentImageView: UIImageView?
    @IBOutlet var contentTextView: UITextView!
    
    // MARK: - Variables
    var itemIndex: Int = 0
    var imageName: String = "" {
        
        didSet {
            
            if let imageView = contentImageView {
                imageView.image = UIImage(named: imageName)
            }
            
        }
    }
    
    
    var contentDetailText: String = "" {
        didSet {
            if let textView = contentTextView {
                textView.text = contentDetailText
                textView.scrollRangeToVisible(NSMakeRange(0, 1))
            }
        }
    }
    
    func checkFontSize () {
        /*if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
            if let textView = contentTextView {
                if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)){
                    textView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
                    textView.textColor = UIColor.blackColor()
                    textView.tintColor = UIColor.blackColor()
                }else if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)){
                    textView.backgroundColor = UIColor.clearColor()
                    textView.textColor = UIColor.whiteColor()
                    textView.tintColor = UIColor.whiteColor()
                }
            }
        }*/
        if(UIScreen.mainScreen().bounds.width <= 320){
            contentTextView.font = UIFont(name: contentTextView.font!.fontName, size: 12.5)
        }else{
            contentTextView.font = UIFont(name: contentTextView.font!.fontName, size: 16)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[提示] 已加載 Start Page Item Controller 之 super.viewDidLoad()")
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            contentTextView.font = UIFont (name: contentTextView.font!.fontName, size: 20)
        }
        
        contentImageView!.image = UIImage(named: imageName)

        contentTextView.text = contentDetailText
        contentTextView.scrollRangeToVisible(NSMakeRange(0, 1))
        
        checkFontSize()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkFontSize", name: "com.arefly.catnap.welcomePageChangeUITextViewBackground", object: nil)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("[提示] 已加載 Start Page Item Controller 之 super.viewWillDisappear()")
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "com.arefly.catnap.welcomePageChangeUITextViewBackground", object: nil)
    }
}