//
//  ViewController.swift
//  WordCounter
//
//  Created by Arefly on 5/7/2015.
//  Copyright (c) 2015 Arefly. All rights reserved.
//

import UIKit
import Foundation
import Async
import MBProgressHUD
import EAIntroView
import GoogleMobileAds

class ViewController: UIViewController, UITextViewDelegate, GADBannerViewDelegate, EAIntroDelegate {

	// MARK: - Basic var
	let appDelegate = (UIApplication.shared.delegate as! AppDelegate)

	let defaults = UserDefaults.standard
	let sharedData = UserDefaults(suiteName: "group.com.arefly.WordCounter")

	// MARK: - Init var
	var adBannerHeight: CGFloat = 0.0

	// MARK: - IBOutlet var
	@IBOutlet var tv: UITextView!

	// MARK: - Navbar var
	var topBarCountButton: UIBarButtonItem!
    var topBarCountButtonType: CountByType!
    var shareButton: UIBarButtonItem!
    var clearButton: UIBarButtonItem!

	// MARK: - keyboardButton var
    var keyBoardToolBar: CustomInputAccessoryWithToolbarView!

    var showedKeyboardButtons = [CountByType: Bool]()

    // We have to keep both `countingKeyboardBarButtonItemsNames` and `countingKeyboardBarButtonItems` as `countingKeyboardBarButtonItems` is not ordered.
	var countingKeyboardBarButtonItemsNames = [CountByType]()
	var countingKeyboardBarButtonItems = [CountByType: UIBarButtonItem]()

	var stableKeyboardBarButtonItemsNames = [String]()
	var stableKeyboardBarButtonItems = [String: UIBarButtonItem]()

	// MARK: - Bool var
	var keyboardShowing = false

	var appFirstLaunch = false
	var appJustUpdate = false

	var presentingOtherView = false

	// MARK: - AdMob var
	var adBannerShowing = false

	//var isZhUser = false

	// MARK: - UI var
	var tvPlaceholderLabel: UILabel!

	// MARK: - Welcome page var
	var intro = EAIntroView()
    
    // MARK: - Color
    var toolbarButtonTintColor: UIColor = {
        if #available(iOS 13, *) {
            return .label
        } else {
            return .black
        }
    }()

	// MARK: - Override func
	override func viewDidLoad() {
		super.viewDidLoad()
		print("準備加載 View Controller 之 viewDidLoad")


		self.title = NSLocalizedString("Main.NavBar.Title", comment: "Word Counter")
        
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        }


		topBarCountButton = UIBarButtonItem()
		topBarCountButton.tintColor = toolbarButtonTintColor
        if WordCounter.isChineseUser() {
            topBarCountButtonType = .chineseWord
        } else {
            topBarCountButtonType = .word
        }
        topBarCountButton.title = WordCounter.getHumanReadableCountString(of: "", by: topBarCountButtonType)
		topBarCountButton.action = #selector(self.topBarCountingButtonClicked(_:))
        topBarCountButton.target = self
		self.navigationItem.setLeftBarButton(topBarCountButton, animated: true)


        clearButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.clearButtonClicked(_:)))
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.shareButtonClicked(sender:)))
        clearButton.tintColor = .systemRed
        self.navigationItem.setRightBarButtonItems([shareButton, clearButton], animated: true)



		if isAppFirstLaunch() {
			appFirstLaunch = true
		}


		let version: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String

		if defaults.object(forKey: "nowVersion") == nil {
			defaults.setValue(version, forKey: "nowVersion")
			appFirstLaunch = true
		} else {
			if defaults.string(forKey: "nowVersion") != version {
				appJustUpdate = true
				defaults.setValue(version, forKey: "nowVersion")
			}
		}


		self.tv.delegate = self
		self.tv.layoutManager.allowsNonContiguousLayout = false
        if #available(iOS 13.0, *) {
            self.tv.backgroundColor = .systemBackground
            self.tv.textColor = .label
        }


		tvPlaceholderLabel = UILabel()
		tvPlaceholderLabel.text = NSLocalizedString("Global.TextView.PlaceHolder.Text", comment: "Type or paste here...")
		tvPlaceholderLabel.font = UIFont.systemFont(ofSize: tv.font!.pointSize)
		tvPlaceholderLabel.sizeToFit()
		tv.addSubview(tvPlaceholderLabel)
		tvPlaceholderLabel.frame.origin = CGPoint(x: 5, y: tv.font!.pointSize / 2)
        if #available(iOS 13.0, *) {
            tvPlaceholderLabel.textColor = .placeholderText
        } else {
            tvPlaceholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        }
		tvPlaceholderLabel.isHidden = !tv.text.isEmpty
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		print("準備加載 View Controller 之 viewWillAppear")

		addToolBarToKeyboard()


		let countMenuItem = UIMenuItem(title: NSLocalizedString("Global.TextView.MenuItem.Count", comment: "Count..."), action: #selector(self.countSelectionWord))
		UIMenuController.shared.menuItems = [countMenuItem]



		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShow(_:)), name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardHide(_:)), name: .UIKeyboardWillHide, object: nil)


		NotificationCenter.default.addObserver(self, selector: #selector(self.doAfterRotate), name: .UIDeviceOrientationDidChange, object: nil)



		NotificationCenter.default.addObserver(self, selector: #selector(self.didBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)

		//2015-12-11: Change to DidEnterBackgroundNotification as it is more suiable in Slide Over view
		NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)


		NotificationCenter.default.addObserver(self, selector: #selector(self.setContentToTextBeforeEnterBackground), name: .catnapSetContentToTextBeforeEnterBackground, object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(self.setContentFromClipBoard), name: .catnapSetContentFromClipBoard, object: nil)






		doAfterRotate()
		//checkScreenWidthToSetButton()


		if defaults.object(forKey: "noAd") == nil {
			defaults.set(false, forKey: "noAd")
		}


		if defaults.object(forKey: "appLaunchTimes") == nil {
			defaults.set(1, forKey: "appLaunchTimes")
		} else {
			defaults.set(defaults.integer(forKey: "appLaunchTimes") + 1, forKey: "appLaunchTimes")
		}
		print("已設定appLaunchTimes值爲\(defaults.integer(forKey: "appLaunchTimes"))")

		if defaults.object(forKey: "everShowPresentReviewAgain") == nil {
			defaults.set(true, forKey: "everShowPresentReviewAgain")
		}


		//appJustUpdate = true
		if defaults.object(forKey: "appLaunchTimesAfterUpdate") == nil {
			defaults.set(-1, forKey: "appLaunchTimesAfterUpdate")
		}
		if appJustUpdate {
			defaults.set(1, forKey: "appLaunchTimesAfterUpdate")
		}

		if defaults.integer(forKey: "appLaunchTimesAfterUpdate") != -1 {
			defaults.set(defaults.integer(forKey: "appLaunchTimesAfterUpdate") + 1, forKey: "appLaunchTimesAfterUpdate")
		}
		print("已設定appLaunchTimesAfterUpdate值爲\(defaults.integer(forKey: "appLaunchTimesAfterUpdate"))")
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		print("準備加載 View Controller 之 viewDidAppear")



		print("用戶 noAd 值爲 \(defaults.bool(forKey: "noAd"))")
		if defaults.bool(forKey: "noAd") == false {
			appDelegate.adMobBannerView.delegate = self
			appDelegate.adMobBannerView.rootViewController = self
			view.addSubview(appDelegate.adMobBannerView)

            if #available(iOS 11.0, *) {
                self.view.addConstraint(
                    NSLayoutConstraint(item: appDelegate.adMobBannerView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view.safeAreaLayoutGuide, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0)
                )
            } else {
                self.view.addConstraint(
                    NSLayoutConstraint(item: appDelegate.adMobBannerView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0)
                )
            }
			self.view.addConstraints([
				NSLayoutConstraint(item: appDelegate.adMobBannerView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: appDelegate.adMobBannerView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0),
				])

			appDelegate.adMobBannerView.load(appDelegate.adMobRequest)
		}



		if appFirstLaunch || appJustUpdate {
			presentingOtherView = true

			presentIntroView()
		}

		if (adBannerShowing) && (adBannerHeight > 0.0) {
			self.tv.contentInset.bottom = adBannerHeight
			self.tv.scrollIndicatorInsets.bottom = adBannerHeight
		} else {
			self.tv.contentInset.bottom = 0
			self.tv.scrollIndicatorInsets.bottom = 0
		}

		//defaults.setBool(true, forKey: "everShowPresentReviewAgain")

		//var everShowPresentReviewAgain = defaults.boolForKey("everShowPresentReviewAgain")
		//var appLaunchTimes = defaults.integerForKey("appLaunchTimes")

        print("everShowPresentReviewAgain的值爲"+String(defaults.bool(forKey: "everShowPresentReviewAgain")))
		if defaults.bool(forKey: "everShowPresentReviewAgain") {
			if !presentingOtherView {
				print("appLaunchTimes的值爲\(defaults.integer(forKey: "appLaunchTimes"))")
				//defaults.setInteger(8, forKey: "appLaunchTimes")
				if defaults.integer(forKey: "appLaunchTimes") % 50 == 0 {
					presentingOtherView = true

					presentReviewAlert()
					//defaults.setInteger(defaults.integerForKey("appLaunchTimes") + 1, forKey: "appLaunchTimes")
				}
			}
		}


		if defaults.integer(forKey: "appLaunchTimesAfterUpdate") != -1 {
			if !presentingOtherView {
				print("appLaunchTimesAfterUpdate的值爲\(defaults.integer(forKey: "appLaunchTimesAfterUpdate"))")
				if defaults.integer(forKey: "appLaunchTimesAfterUpdate") % 88 == 0 {
					presentingOtherView = true

					presentUpdateReviewAlert()
					//defaults.setInteger(defaults.integerForKey("appLaunchTimes") + 1, forKey: "appLaunchTimes")
				}
			}
		}

		if !presentingOtherView {
			startEditing()
		}
	}


	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		print("準備加載 View Controller 之 viewWillDisappear")

		appDelegate.adMobBannerView.removeFromSuperview()

		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)

		NotificationCenter.default.removeObserver(self, name: .UIDeviceOrientationDidChange, object: nil)

		NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
		NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)

		NotificationCenter.default.removeObserver(self, name: .catnapSetContentToTextBeforeEnterBackground, object: nil)
		NotificationCenter.default.removeObserver(self, name: .catnapSetContentFromClipBoard, object: nil)

		//NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		endEditing()
	}

	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		if action == #selector(self.countSelectionWord) {
			if !(getTextViewSelectionText(self.tv).isEmpty) {
				return true
			}
			return false
		}
		return super.canPerformAction(action, withSender: sender)
	}


	// MARK: - Screen config func
	func checkScreenWidthToSetButton () {
		print("準備加載 checkScreenWidthToSetButton")

		showedKeyboardButtons = [
            .word: false,
            .character: false,
            .sentence: false,
            .paragraph: false,
            .chineseWord: false,
            .chineseWordWithoutPunctuation: false,
		]

		let bounds = UIApplication.shared.keyWindow?.bounds
		let width = bounds!.size.width
		let height = bounds!.size.height
		print("屏幕高度：\(height)、屏幕寬度：\(width)")

		switch width {
		case 0..<330:
            showedKeyboardButtons[.sentence] = true
			break
		case 330..<750:
            showedKeyboardButtons[WordCounter.isChineseUser() ? .chineseWordWithoutPunctuation : .character] = true
            showedKeyboardButtons[.sentence] = true
            break
        default:
            if (WordCounter.isChineseUser()) {
                showedKeyboardButtons[.chineseWord] = true
                showedKeyboardButtons[.chineseWordWithoutPunctuation] = true
            }
            showedKeyboardButtons[.word] = true
            showedKeyboardButtons[.character] = true
            showedKeyboardButtons[.sentence] = true
            showedKeyboardButtons[.paragraph] = true
		}

		updateToolBar()

		//updateTextViewCounting()
		handleTextViewChange(self.tv)      // Call handleTextViewChange manually
	}

	@objc func doAfterRotate () {
		print("準備加載 doAfterRotate")

		if adBannerShowing {
			adBannerHeight = getCurrentAdBannerFrame().height
		}
		print("已獲取adBanner高度：\(adBannerHeight)")

		if !keyboardShowing {
			if (adBannerShowing) && (adBannerHeight > 0.0) {
				self.tv.contentInset.bottom = adBannerHeight
				self.tv.scrollIndicatorInsets.bottom = adBannerHeight
			} else {
				self.tv.contentInset.bottom = 0
				self.tv.scrollIndicatorInsets.bottom = 0
			}
		}

		checkScreenWidthToSetButton()
	}

	// MARK: - Keyboard func
	@objc func keyboardShow(_ n: Notification) {
		keyboardShowing = true

		setTextViewSize(n)

		checkScreenWidthToSetButton()

		//updateTextViewCounting()
        handleTextViewChange(self.tv)
	}

	func setTextViewSize (_ n: Notification) {
		if (keyboardShowing) {
			let d = n.userInfo!
			var r = (d[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
			r = self.tv.convert(r, from: nil)
            
            var height = r.size.height
            if #available(iOS 11.0, *) {
                // https://stackoverflow.com/a/48693623/2603230
                height -= self.view.safeAreaInsets.bottom
            }
			self.tv.contentInset.bottom = height
			self.tv.scrollIndicatorInsets.bottom = height
		}

		//self.tv.contentInset.top = 0
		//self.tv.scrollIndicatorInsets.top = 0
	}

	@objc func keyboardHide(_ n: Notification) {
		let selectedRangeBeforeHide = tv.selectedRange

		keyboardShowing = false

		if (adBannerShowing) && (adBannerHeight > 0.0) {
			self.tv.contentInset.bottom = adBannerHeight
			self.tv.scrollIndicatorInsets.bottom = adBannerHeight
		} else {
			self.tv.contentInset.bottom = 0
			self.tv.scrollIndicatorInsets.bottom = 0
		}

		self.tv.contentInset.top = 0
		self.tv.scrollIndicatorInsets.top = 0

		tv.scrollRangeToVisible(selectedRangeBeforeHide)
		tv.selectedRange = selectedRangeBeforeHide
	}

	func addToolBarToKeyboard(){
        // https://stackoverflow.com/a/58524360/2603230
		keyBoardToolBar = CustomInputAccessoryWithToolbarView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))


		stableKeyboardBarButtonItemsNames = [String]()      //Empty stableKeyboardBarButtonItemsNames first

		stableKeyboardBarButtonItems["FlexSpace"] = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		stableKeyboardBarButtonItemsNames.append("FlexSpace")

        stableKeyboardBarButtonItems["Done"] = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonAction))
		stableKeyboardBarButtonItemsNames.append("Done")

		let infoButton: UIButton = UIButton(type: UIButtonType.infoLight)
		infoButton.addTarget(self, action: #selector(self.infoButtonAction), for: UIControlEvents.touchUpInside)
		stableKeyboardBarButtonItems["Info"] = UIBarButtonItem(customView: infoButton)
		stableKeyboardBarButtonItemsNames.append("Info")


        countingKeyboardBarButtonItemsNames = [.chineseWord, .chineseWordWithoutPunctuation, .word, .character, .sentence, .paragraph];
		for name in countingKeyboardBarButtonItemsNames {
			countingKeyboardBarButtonItems[name] = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.countResultButtonAction))
			countingKeyboardBarButtonItems[name]!.tintColor = toolbarButtonTintColor
		}


		updateToolBar()
        
        self.tv.inputAccessoryView = keyBoardToolBar
	}

	func updateToolBar() {
		var barItems = [UIBarButtonItem]()

		for name in countingKeyboardBarButtonItemsNames {
			if showedKeyboardButtons[name] == true {
				barItems.append(countingKeyboardBarButtonItems[name]!)
			}
		}
		for name in stableKeyboardBarButtonItemsNames {
			barItems.append(stableKeyboardBarButtonItems[name]!)
		}

        if keyBoardToolBar != nil {
            keyBoardToolBar.toolbar.setItems(barItems, animated: true)
            keyBoardToolBar.toolbar.setNeedsLayout()
        }

		/*keyBoardToolBar.sizeToFit()
		keyBoardToolBar.frame.size.height = 44*/

        updateTextViewCounting()
	}

	// MARK: - Textview related func
	/*
	func endEditingIfFullScreen() {
	let isFullScreen = CGRectEqualToRect((UIApplication.sharedApplication().keyWindow?.bounds)!, UIScreen.mainScreen().bounds)

	print("目前窗口是否處於全屏狀態：\(isFullScreen)")

	if isFullScreen {
	endEditing()
	}
	}
	*/

	@objc func countSelectionWord() {
		print("準備加載 countSelectionWord")
		print("即：已準備顯示所選文字區域的字數統計")
		let selectedText = getTextViewSelectionText(self.tv)
		showCountResultAlert(selectedText)
	}

	func getTextViewSelectionText(_ tv: UITextView) -> String {
		if let selectedRange = tv.selectedTextRange {
			if let selectedText = tv.text(in: selectedRange) {
				return selectedText
			}
		}
		return ""
	}

	func replaceTextViewContent(_ text: String) {
		self.tv.text = text
		self.textViewDidChange(self.tv)      // Call textViewDidChange manually
	}

	func endEditing() {
		self.tv.resignFirstResponder()
		//self.tv.endEditing(true)
		//self.view.endEditing(true)
	}

	func startEditing() {
		self.tv.becomeFirstResponder()
	}

	func clearContent() {
		endEditing()

		self.replaceTextViewContent("")

		doAfterRotate()
	}

	func textViewDidChange(_ textView: UITextView) {
		handleTextViewChange(textView)
        self.storeText(textView.text)
	}
    
    func handleTextViewChange(_ textView: UITextView) {
        tvPlaceholderLabel.isHidden = !textView.text.isEmpty

        updateTextViewCounting()
    }

	func updateTextViewCounting () {
		//var wordTitle = ""

        var titles: [CountByType: String] = [:]

		if let myText = self.tv.text {
			Async.background {
                if (WordCounter.isChineseUser()) {
                    if myText.isEmptyOrContainsChineseCharacters {
                        self.topBarCountButtonType = .chineseWord
                    } else {
                        self.topBarCountButtonType = .word
                    }
                }
                
                titles[self.topBarCountButtonType] = WordCounter.getHumanReadableCountString(of: myText, by: self.topBarCountButtonType, shouldUseShortForm: true)
                for (type, enabled) in self.showedKeyboardButtons {
                    if (!enabled) {
                        continue
                    }
                    titles[type] = WordCounter.getHumanReadableCountString(of: myText, by: type, shouldUseShortForm: true)
                }
				}.main {
                    self.topBarCountButton.title = titles[self.topBarCountButtonType]

					for name in self.countingKeyboardBarButtonItemsNames {
						self.countingKeyboardBarButtonItems[name]!.title = ""
						self.countingKeyboardBarButtonItems[name]!.title = titles[name]
					}

					//print(titles["Sentence"])
			}
		}
	}

	@objc func setContentFromClipBoard() {
		print("準備加載 setContentFromClipBoard")

		if let clipBoard = UIPasteboard.general.string {
			print("已獲取用戶剪貼簿內容：\(clipBoard)")
			if (self.tv.text.isEmpty) || (self.tv.text == clipBoard) {
				Async.main {
					self.replaceTextViewContent(clipBoard)
				}
			} else {
				let replaceContentAlert = UIAlertController(
					title: NSLocalizedString("Global.Alert.BeforeReplaceTextViewToClipboard.Title", comment: "Replace current contents with clipboard contents?"),
					message: NSLocalizedString("Global.Alert.BeforeReplaceTextViewToClipboard.Content", comment: "NOTICE: This action is irreversible!"),
					preferredStyle: .alert)

				replaceContentAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Yes", comment: "Yes"), style: .default, handler: { (action: UIAlertAction) in
					print("用戶已按下確定替換內容為剪切版內容")
					self.replaceTextViewContent(clipBoard)
				}))

				replaceContentAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Close", comment: "Close"), style: .cancel, handler: { (action: UIAlertAction) in
					print("用戶已按下取消按鈕")
				}))

				Async.main {
					self.present(replaceContentAlert, animated: true, completion: nil)
				}
			}
		}
	}

	@objc func setContentToTextBeforeEnterBackground() {
		print("準備加載 setContentToTextBeforeEnterBackground")

		if let textBeforeEnterBackground = defaults.string(forKey: "textBeforeEnterBackground") {
			if textBeforeEnterBackground != self.tv.text {
				Async.main {
					self.replaceTextViewContent(textBeforeEnterBackground)
				}
			}
		}

	}


	// MARK: - Button action func
	@objc func clearButtonClicked(_ sender: AnyObject) {
		let keyboardShowingBefore = keyboardShowing

		endEditing()

		let clearContentAlert = UIAlertController(
			title: NSLocalizedString("Global.Alert.BeforeClear.Title", comment: "Clear all content?"),
			message: NSLocalizedString("Global.Alert.BeforeClear.Content", comment: "WARNING: This action is irreversible!"),
			preferredStyle: .alert)

		clearContentAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Yes", comment: "Yes"), style: .destructive, handler: { (action: UIAlertAction) in
			print("用戶已按下確定清空按鈕")
			self.clearContent()
			self.startEditing()
		}))

		clearContentAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Close", comment: "Close"), style: .cancel, handler: { (action: UIAlertAction) in
			print("用戶已按下取消清空按鈕")
			if keyboardShowingBefore {
				self.startEditing()
			}
		}))

		Async.main {
			self.present(clearContentAlert, animated: true, completion: nil)
		}
	}
    
    @objc func shareButtonClicked(sender: UIBarButtonItem) {
        endEditing()

        // https://stackoverflow.com/a/37939782/2603230
        let activityViewController: UIActivityViewController = UIActivityViewController(
            activityItems: [self.tv.text], applicationActivities: nil)

        activityViewController.popoverPresentationController?.barButtonItem = sender
        //activityViewController.popoverPresentationController?.permittedArrowDirections = .up

        if #available(iOS 13.0, *) {
            /*activityViewController.activityItemsConfiguration = [
                UIActivity.ActivityType.copyToPasteboard
            ] as? UIActivityItemsConfigurationReading*/
        }

        Async.main {
            self.present(activityViewController, animated: true, completion: nil)
        }
    }

	@objc func infoButtonAction() {
		self.performSegue(withIdentifier: "goInfo", sender: nil)
	}


	@objc func countResultButtonAction() {
		showCountResultAlert(self.tv.text)
	}

	func showCountResultAlert(_ text: String) {
		let keyboardShowingBefore = keyboardShowing

		endEditing()

		let progressHUD = MBProgressHUD.showAdded(to: self.view.window!, animated: true)
		progressHUD.label.text = NSLocalizedString("Global.ProgressingHUD.Label.Counting", comment: "Counting...")

        var message: String = ""
		Async.background {
            message = WordCounter.getHumanReadableSummary(of: text, by: WordCounter.getAllTypes(for: text))
			}.main {
				MBProgressHUD.hide(for: self.view.window!, animated: true)

				let alertTitle = NSLocalizedString("Global.Alert.Counter.Title", comment: "Counter")

				let countingResultAlert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
				countingResultAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Button.Done", comment: "Done"), style: .cancel, handler: { (action: UIAlertAction) in
					print("用戶已按下確定按鈕")
					if keyboardShowingBefore {
						self.startEditing()
					}
				}))
				self.present(countingResultAlert, animated: true, completion: nil)
		}
	}


	@objc func topBarCountingButtonClicked(_ sender: AnyObject) {
		countResultButtonAction()
	}

	@objc func doneButtonAction() {
		endEditing()
	}



	// MARK: - AdMob func
	func getCurrentAdBannerFrame() -> CGRect {
		return self.appDelegate.adMobBannerView.frame
	}

	func adViewWillPresentScreen(_ bannerView: GADBannerView) {
		print("準備加載 adViewWillPresentScreen")
		print("即：用戶已點擊AdMob廣告")
		endEditing()
	}

	func adViewDidDismissScreen(_ bannerView: GADBannerView) {
		print("準備加載 adViewDidDismissScreen")
		print("即：用戶已關閉AdMob廣告")
		startEditing()
	}


	func showAds() {
		adBannerShowing = true

		adBannerHeight = getCurrentAdBannerFrame().height

		if !keyboardShowing {
			self.tv.contentInset.bottom = adBannerHeight
			self.tv.scrollIndicatorInsets.bottom = adBannerHeight
		}
	}

	func adViewDidReceiveAd(_ banner: GADBannerView) {
		print("準備加載 adViewDidReceiveAd")
		print("即：AdMob已成功加載！")

		if !adBannerShowing {
			self.appDelegate.adMobBannerView.isHidden = false
			self.appDelegate.adMobBannerView.alpha = 0
			UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
				self.appDelegate.adMobBannerView.alpha = 1
			}, completion: {
				(value: Bool) in
				// DO NOTHING
			})

			showAds()
		}
	}


	func hideAds() {
		adBannerShowing = false

		adBannerHeight = 0.0

		if !keyboardShowing {
			self.tv.contentInset.bottom = 0
			self.tv.scrollIndicatorInsets.bottom = 0
		}
	}

	func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
		print("準備加載 adView: didFailToReceiveAdWithError")
		print("即：AdMob加載錯誤：\(error.localizedDescription)")

		if adBannerShowing {
			UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
				self.appDelegate.adMobBannerView.alpha = 0
			}, completion: {
				(value: Bool) in
				self.appDelegate.adMobBannerView.isHidden = true
			})

			hideAds()
		}
	}

	// MARK: - Intro View
	func presentIntroView() {
		let screenWidth = self.view.bounds.size.width
		let screenHeight = self.view.bounds.size.height

		let contentImages = [
            "1-4-DarkMode.png",
            "1-4-MoreCountingType.png",
            "1-4-ActionExtension.png",
			"1-4-TodayWidget.png",
			"1-4-About.png",
			]

		let contentTitleTexts = [
            NSLocalizedString("Welcome.Version.1-4.Title.DarkMode", comment: ""),
            NSLocalizedString("Welcome.Version.1-4.Title.MoreCountingType", comment: ""),
            NSLocalizedString("Welcome.Version.1-4.Title.ActionExtension", comment: ""),
			NSLocalizedString("Welcome.Version.1-4.Title.TodayWidget", comment: ""),
			NSLocalizedString("Welcome.Global.Title.About", comment: "Thanks!"),
			]

		let contentDetailTexts = [
			NSLocalizedString("Welcome.Version.1-4.Text.DarkMode", comment: ""),
            NSLocalizedString("Welcome.Version.1-4.Text.MoreCountingType", comment: ""),
			NSLocalizedString("Welcome.Version.1-4.Text.ActionExtension", comment: ""),
			NSLocalizedString("Welcome.Version.1-4.Text.TodayWidget", comment: ""),
			NSLocalizedString("Welcome.Global.Text.About", comment: ""),
			]

		var introPages = [EAIntroPage]()

		for (index, _) in contentTitleTexts.enumerated() {

			let page = EAIntroPage()
			page.title = contentTitleTexts[index]
			page.desc = contentDetailTexts[index]

			if (index == contentImages.count-1) {
				//About Content
				page.descFont = UIFont(name: (page.descFont?.fontName)!, size: 12)
			}

			//print("WOW!: \(page.titlePositionY)")

			let titlePositionFromBottom = page.titlePositionY

			let imageView = UIImageView(image: UIImage(named: contentImages[index]))
			imageView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight-titlePositionFromBottom-100)
			imageView.contentMode = .scaleAspectFit

			page.titleIconView = imageView
			//page.titleIconPositionY = 30

			page.bgColor = self.view.tintColor

			introPages.append(page)
		}

		intro = EAIntroView(frame: self.view.bounds, andPages: introPages)
		intro.delegate = self
		intro.show(in: self.view, animateDuration: 0.5)
		intro.showFullscreen()
		intro.skipButton.setTitle(NSLocalizedString("Welcome.Global.Button.Skip", comment: "Skip"), for: UIControlState())
		intro.pageControlY = 50
	}

	func introDidFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
		presentingOtherView = false
		appFirstLaunch = false
		appJustUpdate = false
		startEditing()
	}

	// MARK: - General func
	@objc func didBecomeActive() {
		print("準備加載 didBecomeActive")

		doAfterRotate()
	}
    
    func storeText(_ tvText: String) {
        //print("準備 storeText \(tvText)")

        defaults.set(tvText, forKey: "textBeforeEnterBackground")
    }

	@objc func didEnterBackground() {
		print("準備加載 didEnterBackground")

        self.storeText(self.tv.text)
	}

	func isAppFirstLaunch() -> Bool{          //檢測App是否首次開啓
		print("準備加載 isAppFirstLaunch")
		if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce") {
			print("App於本機並非首次開啓")
			return false
		} else {
			defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
			print("App於本機首次開啓")
			return true
		}
	}

	func presentReviewAlert() {
		let reviewAlert = UIAlertController(
			title: NSLocalizedString("Global.Alert.PlzRate.Title", comment: "Thanks!"),
			message: String.localizedStringWithFormat(
				NSLocalizedString("Global.Alert.PlzRate.Content", comment: "You have used Word Counter Tools for %d times! Love it? Can you take a second to rate our app?"),
				defaults.integer(forKey: "appLaunchTimes")),
			preferredStyle: .alert)

		reviewAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Alert.PlzRate.Button.Yes", comment: "Sure!"), style: .default, handler: { (action: UIAlertAction) in
			print("用戶已按下發表評論按鈕")
			self.defaults.set(-1, forKey: "appLaunchTimesAfterUpdate")       // Do not show update alert for this version too
			self.defaults.set(false, forKey: "everShowPresentReviewAgain")
			UIApplication.shared.openURL(BasicConfig.appStoreReviewUrl! as URL)
			self.presentingOtherView = false
		}))

		reviewAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Alert.PlzRate.Button.Later", comment: "Not now"), style: .default, handler: { (action: UIAlertAction) in
			print("用戶已按下以後再說按鈕")
			self.defaults.set(true, forKey: "everShowPresentReviewAgain")
			self.startEditing()
			self.presentingOtherView = false
		}))

		reviewAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Alert.PlzRate.Button.Cancel", comment: "No, thanks!"), style: .cancel, handler: { (action: UIAlertAction) in
			print("用戶已按下永遠再不顯示按鈕")
			self.defaults.set(-1, forKey: "appLaunchTimesAfterUpdate")       // Do not show update alert for this version too
			self.defaults.set(false, forKey: "everShowPresentReviewAgain")
			self.startEditing()
			self.presentingOtherView = false
		}))

		Async.main {
			self.present(reviewAlert, animated: true, completion: nil)
		}
	}

	func presentUpdateReviewAlert() {
		let reviewAlert = UIAlertController(
			title: NSLocalizedString("Global.Alert.PlzRateUpdate.Title", comment: "Thanks for update!"),
			message: String.localizedStringWithFormat(
				NSLocalizedString("Global.Alert.PlzRateUpdate.Content", comment: "You have used Word Counter Tools for %1$d times since you updated to Version %2$@! Love this update? Can you take a second to rate our app?"),
				defaults.integer(forKey: "appLaunchTimesAfterUpdate"),
				Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
			),
			preferredStyle: .alert)

		reviewAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Alert.PlzRateUpdate.Button.Yes", comment: "Sure!"), style: .default, handler: { (action: UIAlertAction) in
			print("用戶已按下發表評論按鈕")
			self.defaults.set(-1, forKey: "appLaunchTimesAfterUpdate")
			UIApplication.shared.openURL(BasicConfig.appStoreReviewUrl! as URL)
			self.presentingOtherView = false
		}))

		reviewAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Alert.PlzRateUpdate.Button.Later", comment: "Not now"), style: .default, handler: { (action: UIAlertAction) in
			print("用戶已按下以後再說按鈕")
			self.startEditing()
			self.presentingOtherView = false
		}))

		reviewAlert.addAction(UIAlertAction(title: NSLocalizedString("Global.Alert.PlzRateUpdate.Button.Cancel", comment: "No for this version, thanks!"), style: .cancel, handler: { (action: UIAlertAction) in
			print("用戶已按下此版本永遠再不顯示按鈕")
			self.defaults.set(-1, forKey: "appLaunchTimesAfterUpdate")
			self.startEditing()
			self.presentingOtherView = false
		}))

		Async.main {
			self.present(reviewAlert, animated: true, completion: nil)
		}
	}
}
