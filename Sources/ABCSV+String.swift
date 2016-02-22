//
//  ABCSV+String.swift
//  ABCSV
//
//  Created by Anders Boberg on 1/27/16.
//  Copyright © 2016 Anders boberg. All rights reserved.
//

import Foundation

extension String {
    /**
     Finds and returns all occurences of a given string in order, from lowest to highest indices.
     */
    func rangesOfString(string:String, options:NSStringCompareOptions, range: Range<Index>?, locale: NSLocale?) -> [Range<Index>] {
        var searchRange = range ?? Range(start: startIndex, end: endIndex)
        var ranges:[Range<Index>] = []
        while let newRange = self.rangeOfString(string,options: options,range: searchRange,locale: locale) {
            ranges += [newRange]
            searchRange.startIndex = newRange.endIndex
        }
        return ranges
    }
    
    func rangesOfString(string:String, options:NSStringCompareOptions, ranges: [Range<Index>], locale: NSLocale?) -> [Range<Index>] {
        var foundRanges:[Range<Index>] = []
        for range in ranges {
            foundRanges += rangesOfString(string, options: options, range: range, locale: locale)
        }
        return foundRanges
    }
}