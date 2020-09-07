//
//  WordCounterClass.swift
//  WordCounter
//
//  Created by Arefly on 7/8/2015.
//  Copyright (c) 2015 Arefly. All rights reserved.
//

import Foundation

enum CountByType: String {
    case character = "Character"
    case word = "Word"
    case sentence = "Sentence"
    case paragraph = "Paragraph"
}


class WordCounter {
	// MARK: - Get string func
	static func getHumanReadableCountString(of string: String, by type: CountByType) -> String {
        let count = getCount(of: string, by: type)

		let words = (count == 1) ?
            NSLocalizedString("Global.Units.\(type.rawValue).Singular", comment: "Singular Unit") :
			NSLocalizedString("Global.Units.\(type.rawValue).Plural", comment: "Plural Unit")

		let returnString = String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text.\(type.rawValue)", comment: "%1$@ %2$@"), String(count), words)

		return returnString
	}

	// MARK: - Get count func
    static func getCount(of string: String, by type: CountByType) -> Int {
        var enumerateSubstringsOptions: NSString.EnumerationOptions;
        switch type {
        case .character:
            enumerateSubstringsOptions = .byComposedCharacterSequences
        case .word:
            enumerateSubstringsOptions = .byWords
        case .sentence:
            enumerateSubstringsOptions = .bySentences
        case .paragraph:
            enumerateSubstringsOptions = .byParagraphs
        }

		var substrings: [String] = []
        string.enumerateSubstrings(in: string.startIndex..., options: enumerateSubstringsOptions) {
            substring, substringRange, enclosingRange, stop in
            if let substring = substring {
                // https://stackoverflow.com/a/27768113/2603230
                if !substring.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    substrings.append(substring)
                }
            }
        }
        return substrings.count
	}
}

extension String {
	var containsChineseCharacters: Bool {
		return self.range(of: "\\p{Han}", options: .regularExpression) != nil
	}
}
