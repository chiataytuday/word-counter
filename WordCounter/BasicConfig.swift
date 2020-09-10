//
//  BasicConfig.swift
//  WordCounter
//
//  Created by Arefly on 12/8/2015.
//  Copyright (c) 2015 Arefly. All rights reserved.
//

import UIKit
import Foundation

class BasicConfig {
	internal static let appStoreShortUrl = URL(string: "http://bit.ly/WordCounter")
    
    // https://stackoverflow.com/a/55876205/2603230
    // https://developer.apple.com/documentation/storekit/skstorereviewcontroller/2851536-requestreview
	internal static let appStoreReviewUrl = URL(string: "https://itunes.apple.com/us/app/word-counter-tools/id1019068052?action=write-review")
	internal static let otherAppsByMe = URL(string: "https://itunes.apple.com/us/developer/xueqin-huang/id1016182704")
	//"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1019068052&onlyLatestVersion=true&pageNumber=0&sortOrdering=1)"
}
