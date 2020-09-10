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
    case chineseWord = "ChineseWord" // Count English word + Chinese characters
    case chineseWordWithoutPunctuation = "ChineseWordWithoutPunctuation" // Count English word + Chinese characters - punctuation characters
    case sentence = "Sentence"
    case paragraph = "Paragraph"
}


class WordCounter {
    static func isChineseUser() -> Bool {
        return Bundle.main.preferredLocalizations.first?.starts(with: "zh") ?? false
    }
    
    static func isSimplifiedChineseUser() -> Bool {
        return Bundle.main.preferredLocalizations.first?.starts(with: "zh-Hans") ?? false
    }
    
	// MARK: - Get string func
    static func getHumanReadableCountString(of string: String, by type: CountByType, shouldUseShortForm: Bool = false) -> String {
        let count = getCount(of: string, by: type)
        
        var useShort = ""
        if shouldUseShortForm && count >= 1000 {
            useShort = ".Short"
        }

		let words = (count == 1) ?
            NSLocalizedString("Global.Units\(useShort).\(type.rawValue).Singular", comment: "Singular Unit") :
			NSLocalizedString("Global.Units\(useShort).\(type.rawValue).Plural", comment: "Plural Unit")

		let returnString = String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text\(useShort).\(type.rawValue)", comment: "%1$@ %2$@"), String(count), words)

		return returnString
	}

	// MARK: - Get count func
    static func getCount(of string: String, by type: CountByType) -> Int {
        var enumerateSubstringsOptions: NSString.EnumerationOptions;
        switch type {
        case .character:
            enumerateSubstringsOptions = .byComposedCharacterSequences
            break
        case .word:
            enumerateSubstringsOptions = .byWords
            break
        case .sentence:
            enumerateSubstringsOptions = .bySentences
            break
        case .paragraph:
            enumerateSubstringsOptions = .byParagraphs
            break
        case .chineseWord, .chineseWordWithoutPunctuation:
            if string.isEmptyOrContainsChineseCharacters {
                return getChineseWordCount(of: string, removeChinesePunctuations: type == .chineseWordWithoutPunctuation)
            } else {
                enumerateSubstringsOptions = .byWords
                break
            }
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
    
    static func getChineseWordCount(of string: String, removeChinesePunctuations: Bool) -> Int {
        // https://developer.apple.com/documentation/foundation/nsregularexpression
        let englishCharacters = "[\\p{Ll}\\p{Lu}\\p{Lt}\\p{Nd}]"
        let resultsStrings = matches(for: "\(englishCharacters)+", in: string)
        //print(resultsStrings)
        //print(resultsRanges)
        var counts = string.count
        for resultsString in resultsStrings {
            counts -= resultsString.count
        }
        counts += resultsStrings.count

        var spacesOrPunctuations = "[\\s"
        // https://stackoverflow.com/a/4328722/2603230
        spacesOrPunctuations += "!\"#\\$%&'\\(\\)\\*\\+,-\\.\\/:;<=>\\?@\\[\\\\\\]\\^_`{\\|}~"
        if removeChinesePunctuations {
            spacesOrPunctuations += "\\W"
        }
        spacesOrPunctuations += "]"
        counts -= matches(for: spacesOrPunctuations, in: string).count

        return counts
    }
    
    // MARK: - Get summary func
    static func getAllTypes(for string: String) -> [CountByType] {
        var types: [CountByType] = [];
        if (isChineseUser() && string.isEmptyOrContainsChineseCharacters) {
            types.append(contentsOf: [.chineseWord, .chineseWordWithoutPunctuation])
        }
        types.append(contentsOf: [.word, .character, .sentence, .paragraph])
        if (!isChineseUser() && string.containsChineseCharacters) {
            types.append(contentsOf: [.chineseWord, .chineseWordWithoutPunctuation])
        }
        return types
    }
    
    static func getHumanReadableSummary(of string: String, by types: [CountByType]) -> String {
        var summary = ""
        for (index, type) in types.enumerated() {
            let countString = WordCounter.getHumanReadableCountString(of: string, by: type);
            
            let localizedString = "Global.Alert.Counter.Content.\(type.rawValue)"

            summary += String.localizedStringWithFormat(NSLocalizedString(localizedString, comment: "Localized string for every counting."), countString)

            if index != types.count - 1 {
                summary += "\n"
            }
        }
        return summary
    }
    
    // MARK: - Related func
    /**
    Search `regex` in `text`
    - Parameter regex:  The regex.
    - Parameter text:   The text.
    - Returns: A new `[string]` with result.
    */
    fileprivate static func matches(for regex: String, in text: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: regex,
                                             options: [])
        let nsString = text as NSString
        let results = regex.matches(in: text, options: [], range: NSMakeRange(0, nsString.length))
        return results.map { nsString.substring(with: $0.range) }
    }
}

// https://stackoverflow.com/q/31244367/2603230
extension String {
	var containsChineseCharacters: Bool {
		return self.range(of: "\\p{Han}", options: .regularExpression) != nil
	}
    
    var isEmptyOrContainsChineseCharacters: Bool {
        return self.isEmpty || self.containsChineseCharacters
    }
}
