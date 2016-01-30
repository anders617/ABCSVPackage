//
//  ABCSV+String.swift
//  ABCSV
//
//  Created by Anders Boberg on 1/27/16.
//  Copyright © 2016 Anders boberg. All rights reserved.
//

import Foundation

extension String {
    func rangesOfString(string:String, options:NSStringCompareOptions, range: Range<Index>?, locale: NSLocale?) -> [Range<Index>] {
        var searchRange = range ?? Range(start: startIndex, end: endIndex)
        var searchStartIndex = searchRange.startIndex
        let searchEndIndex = searchRange.endIndex
        var ranges:[Range<Index>] = []
        while searchStartIndex < searchEndIndex {
            if let newRange = self.rangeOfString(string,
                options: options,
                range: searchRange,
                locale: locale) {
                    ranges += [newRange]
                    searchStartIndex = newRange.endIndex
                    searchRange.startIndex = newRange.endIndex
            } else {
                searchStartIndex = searchEndIndex
            }
        }
        return ranges
    }
}