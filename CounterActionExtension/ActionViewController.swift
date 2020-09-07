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

class ActionViewController: UIViewController {

	@IBOutlet weak var contentTextView: UITextView!
	@IBOutlet weak var doneButton: UIBarButtonItem!

	var userText: String? = nil

	var progressBar = UIView()

	override func viewDidLoad() {
		super.viewDidLoad()
		print("[提示] 準備加載 Action View Controller 之 viewDidLoad")

		if UIDevice.current.userInterfaceIdiom == .pad {
			self.preferredContentSize = CGSize(width: 550, height: 600)
		}

		self.title = NSLocalizedString("Main.NavBar.Title", comment: "Word Counter")

		doneButton.title = NSLocalizedString("Global.Button.Done", comment: "Done")
		doneButton.action = #selector(self.closeWindow)

		if let textItem = self.extensionContext!.inputItems[0] as? NSExtensionItem {
			for textItemProvider in textItem.attachments! {
				if let textItemProvider = textItemProvider as? NSItemProvider {
					print("textItemProvider: \(textItemProvider)")
					if textItemProvider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
						textItemProvider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil, completionHandler: {(string, error) in
							if let convertedString = string as? String {
								self.userText = convertedString
							}
						})
					}
				}
			}
		}

	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		print("[提示] 準備加載 Action View Controller 之 viewWillAppear")

		contentTextView.text = userText
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		print("[提示] 準備加載 Action View Controller 之 viewDidAppear")

		if (userText ?? "").isEmpty {
			print("[警告] 用戶 userText 爲空！")
			self.closeWindow()
		}else{
			self.showCountResult(userText!)
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func showCountResult(_ text: String) {
		self.progressBar = LoadingUIView.getProgressBar(
			self.view.window!,
			msg: NSLocalizedString("Global.ProgressingHUD.Label.Counting", comment: "Counting..."),
			indicator: true)

		self.view.window!.addSubview(self.progressBar)
		self.view.window!.isUserInteractionEnabled = false
		self.progressBar.center = self.view.center


        let itemNames: [CountByType] = [.word, .character, .sentence, .paragraph]

        var message: String = ""
		// Cannot use Async since Swift Framework is not allowed using in app extension :(
		DispatchQueue.global(qos: .background).async {
            message = WordCounter.getHumanReadableSummary(of: text, by: itemNames)
			DispatchQueue.main.async {
				self.progressBar.removeFromSuperview()
				self.view.window!.isUserInteractionEnabled = true

				let alertTitle = NSLocalizedString("Global.Alert.Counter.Title", comment: "Counter")

				let countingResultAlert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
				countingResultAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Done", comment: "Done"), style: .cancel, handler: { (action: UIAlertAction) in
					print("[提示] 用戶已按下確定按鈕")
					self.closeWindow()
				}))

				self.present(countingResultAlert, animated: true, completion: nil)
			}
		}
	}

	@objc func closeWindow() {
		// Return any edited content to the host app.
		// This template doesn't do anything, so we just echo the passed in items.
		self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
	}
}
