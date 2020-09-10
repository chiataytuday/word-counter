//
//  ProgressHUD.swift
//  WordCounter
//
//  Created by Jason Ho on 22/12/2015.
//  Copyright © 2015 Arefly. All rights reserved.
//

import UIKit
import Foundation

class LoadingUIView {
    // We have to use our own view as it is is difficult to use Cocoapods in Extension :(
    class func getProgressBar(_ view: UIView, msg: String, indicator: Bool ) -> UIView {
        print("[提示] 準備創建標籤爲 \(msg) 的載入中提示")

        var messageFrame = UIView()
        var activityIndicator = UIActivityIndicatorView()
        var strLabel = UILabel()

        let msgNSString: NSString = msg as NSString
        let msgSize: CGSize = msgNSString.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17.0)])

        let strLabelWidth: CGFloat = msgSize.width

        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: strLabelWidth, height: 50))
        strLabel.text = msg
        strLabel.textColor = UIColor.white

        let messageFrameWidth: CGFloat = strLabelWidth + 70.0
        let messageFrameHeight: CGFloat = 50.0

        messageFrame = UIView(frame: CGRect(x: view.frame.midX - messageFrameWidth/2, y: view.frame.midY - messageFrameHeight/2 , width: messageFrameWidth, height: messageFrameHeight))
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
        if indicator {
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.startAnimating()
            messageFrame.addSubview(activityIndicator)
        }

        messageFrame.addSubview(strLabel)

        return messageFrame
    }
}
