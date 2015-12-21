//
//  StartPageViewController.swift
//  Catnap
//
//  Created by Arefly on 3/7/2015.
//  Copyright (c) 2015年 Arefly. All rights reserved.
//

import Foundation
import UIKit

class StartPageViewController: UIViewController, UIPageViewControllerDataSource {
    
    // MARK: - Variables
    private var pageViewController: UIPageViewController?
    
    // Initialize it right away here
    private let contentImages = ["1_1_today_widget.png", "1_1_today_widget_how.png", "1_1_too_many_charas.png", "1_1_thanks.png"]
    
    private let contentDetailTexts = [
        NSLocalizedString("Welcome.Version.1-1.Text.TodayWidget.Introduction", comment: "Check how many words is there in your clipboard using Today Widget inside Notification Centre!"),
        NSLocalizedString("Welcome.Version.1-1.Text.TodayWidget.How", comment: "Add widget by \"Edit\" button in Today view"),
        NSLocalizedString("Welcome.Version.1-1.Text.TooManyCharacter", comment: "If characters is larger than 1500, Word Counter Tools will automatically change to manual mode in order to prevent the serious lag."),
        NSLocalizedString("Welcome.Global.Text.About", comment: "We promise to keep working on Word Counter Tools and make it better. If you have any questions or suggestions for this app, feel free to contact Arefly at eflyjason@gmail.com. We will try our best. Thanks! :)")]
        //NSLocalizedString("WELCOME_1_1_THANKS", comment: "- Developer: Jason Ho (Arefly)\n- Email: eflyjason@gmail.com\n- Website: http://www.arefly.com/")]
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[提示] 已加載 Start Page View Controller 之 super.viewDidLoad()")
        
        createPageViewController()
        setupPageControl()
    }
    
    private func createPageViewController() {
        
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("PageController") as! UIPageViewController
        pageController.dataSource = self
        
        if contentDetailTexts.count > 0 {
            let firstController = getItemController(0)! as UIViewController
            let startingViewControllers: NSArray = [firstController]
            pageController.setViewControllers((startingViewControllers as! [UIViewController]), direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
        
        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.lightGrayColor()
        appearance.currentPageIndicatorTintColor = UIColor.blackColor()
        appearance.backgroundColor = UIColor.clearColor()
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! StartPageItemController
        
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex-1)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! StartPageItemController
        
        if itemController.itemIndex+1 < contentDetailTexts.count {
            return getItemController(itemController.itemIndex+1)
        }
        
        return nil
    }
    
    private func getItemController(itemIndex: Int) -> StartPageItemController? {
        
        if itemIndex < contentDetailTexts.count {
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier("ItemController") as! StartPageItemController
            pageItemController.itemIndex = itemIndex
            pageItemController.imageName = contentImages[itemIndex]
            pageItemController.contentDetailText = contentDetailTexts[itemIndex]
            return pageItemController
        }
        
        return nil
    }
    
    // MARK: - Page Indicator
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return contentDetailTexts.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}
