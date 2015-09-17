//
//  WordCounterClass.swift
//  WordCounter
//
//  Created by Arefly on 7/8/2015.
//  Copyright (c) 2015年 Arefly. All rights reserved.
//

import Foundation

class WordCounter {
    func characterCount(s: String) -> Int {
        var characterCounts = 0
        let modifiedCharacter = Array(s.characters).filter({
            let s = String($0) as String?
            if !(s != nil) { return false }
            if (s!).characters.count < 1 { return false }
            if (s == "\n") { return false }
            if s! == " " { return false }
            return true
        })
        characterCounts = modifiedCharacter.count
        
        /*
        if(characterCounts >= 1500){
            tooManyWords = true
        }
*/
        
        return characterCounts
    }
    
    func paragraphCount(s: String) -> Int {
        var paragraphCounts = 0
        let lines = s.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
        let modifiedLines = lines.filter({
            let s = $0 as String?
            if !(s != nil) { return false }
            if (s!).characters.count < 1 { return false }
            return true
        })
        paragraphCounts = modifiedLines.count
        return paragraphCounts
    }
    
    
    func wordCount(s: String) -> Int {
        var counts = 0
        let lines = s.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
        let joinedString = lines.joinWithSeparator(" ")
        let words = joinedString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        let modifiedWords = words.filter({
            let s = $0 as String?
            if !(s != nil) { return false }
            if (s!).characters.count < 1 { return false }
            //if(self.isZhUser){
            if(s!.containsChineseCharacters){
                var results = self.matchesForRegexInText("\\p{Han}", text: s!)
                var sArray: Array = Array((s!).characters)
                if(String(sArray[0]) != results[0]){
                    counts += 1
                }
                //println(sArray[count(sArray)-1])
                //println(results[count(results)-1])
                if(String(sArray[sArray.count-1]) != results[results.count-1]){
                    counts += 1
                }
                counts += results.count
                return false
            }
            //}
            return true
        })
        
        counts += modifiedWords.count
        
        return counts
    }
    
    private func matchesForRegexInText(regex: String!, text: String!) -> [String] {
        let regex = try! NSRegularExpression(pattern: regex,
            options: [])
        let nsString = text as NSString
        let results = regex.matchesInString(text, options: [], range: NSMakeRange(0, nsString.length)) 
        return results.map { nsString.substringWithRange($0.range)}
    }
}

extension String {
    var containsChineseCharacters: Bool {
        return self.rangeOfString("\\p{Han}", options: .RegularExpressionSearch) != nil
    }
}