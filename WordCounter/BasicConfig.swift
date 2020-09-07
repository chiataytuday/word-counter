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
    
    // TODO: TRY USING THE NEW REVIEW SDK
    // https://stackoverflow.com/a/55876205/2603230
	internal static let appStoreReviewUrl = URL(string: "https://itunes.apple.com/us/app/word-counter-tools/id1019068052")
	internal static let otherAppsByMe = URL(string: "https://itunes.apple.com/us/developer/xueqin-huang/id1016182704")
	//"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1019068052&onlyLatestVersion=true&pageNumber=0&sortOrdering=1)"

	internal static let adMobUnitId = "ca-app-pub-4890802000578360/7078656138"
}
