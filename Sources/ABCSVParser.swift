//
//  ABCSVParser.swift
//  ABCSV
//
//  Created by Anders Boberg on 2/16/16.
//  Copyright © 2016 Anders boberg. All rights reserved.
//

import Foundation

public protocol ABCSVParserDelegate {
    mutating func csvParserDidStartDocument()
    mutating func csvParserDidEndDocument()
    mutating func csvParser(parser: ABCSVParser, foundCell contents:String, row:Int, column:Int)
    mutating func csvParser(parser: ABCSVParser, didStartRow row:Int)
    mutating func csvParser(parser: ABCSVParser, didEndRow row:Int, columnCount:Int)
}

public class ABCSVParser {
    static let defaultRowSeparator:Array<Character> = ["\n","\r"]
    static let defaultValueSeparator:Array<Character> = [","]
    static let defaultQuoteCharacter:Array<Character> = ["\""]
    
    public let rowSeparators:Array<Character>
    public let valueSeparators:Array<Character>
    public let quoteCharacters:Array<Character>
    public let contents:String
    
    public var delegate:ABCSVParserDelegate?
    public var shouldIgnoreQuotedText = true
    public var shouldReplaceCLRF = true
    
    private var rowNum:Int = 0
    private var columnNum:Int = 0
    
    public init(contents:String,
        rowSeparators:Array<Character> = ABCSVParser.defaultRowSeparator,
        valueSeparators:Array<Character> = ABCSVParser.defaultValueSeparator,
        quoteCharacters:Array<Character> = ABCSVParser.defaultQuoteCharacter) {
            self.rowSeparators = rowSeparators
            self.valueSeparators = valueSeparators
            self.quoteCharacters = quoteCharacters
            self.contents = contents
    }
    
    //TODO:Special case for single sets
    public func parse() {
        var cellContents:String = ""
        var characters:String.CharacterView
        if shouldReplaceCLRF {
            characters = contents.stringByReplacingOccurrencesOfString("\r\n", withString: String(rowSeparators.first!)).characters
        } else {
            characters = contents.characters
        }
        var index = characters.startIndex
        var c:Character
        startDocument(&characters, &cellContents, &index)
        while index < characters.endIndex {
            c = characters[index]
            switch c {
            case valueSeparators: parseValueSeparator(&characters, &cellContents, &index)
            case quoteCharacters: parseQuotedText(&characters, &cellContents, &index)
            case rowSeparators: parseRowSeparator(&characters, &cellContents, &index)
            default: cellContents.append(c)
            }
            index = index.successor()
        }
        endDocument(&characters, &cellContents, &index)
    }
    
    private func startDocument(inout characters:String.CharacterView, inout _ cellContents:String, inout _ index:String.Index) {
        cellContents.removeAll(keepCapacity: true)
        rowNum = 0
        columnNum = 0
        delegate?.csvParserDidStartDocument()
        delegate?.csvParser(self, didStartRow: 0)
    }
    
    private func endDocument(inout characters:String.CharacterView, inout _ cellContents:String, inout _ index:String.Index) {
        delegate?.csvParser(self, foundCell: cellContents, row: rowNum, column: columnNum)
        delegate?.csvParser(self, didEndRow: rowNum, columnCount: columnNum+1)
        delegate?.csvParserDidEndDocument()
    }
    
    private func parseRowSeparator(inout characters:String.CharacterView, inout _ cellContents:String, inout _ index:String.Index) {
        parseValueSeparator(&characters, &cellContents, &index)
        delegate?.csvParser(self, didEndRow: rowNum, columnCount: columnNum)
        rowNum += 1
        columnNum = 0
        delegate?.csvParser(self, didStartRow: rowNum)
    }
    
    private func parseValueSeparator(inout characters:String.CharacterView, inout _ cellContents:String, inout _ index:String.Index) {
        delegate?.csvParser(self, foundCell: cellContents, row: rowNum, column: columnNum)
        columnNum += 1
        cellContents.removeAll(keepCapacity: true)
    }
    
    private func parseQuotedText(inout characters:String.CharacterView, inout _ cellContents:String, inout _ index:String.Index) {
        if !shouldIgnoreQuotedText {
            cellContents.append(characters[index])
            return
        }
        var c:Character
        index = index.successor()
        while index < characters.endIndex {
            c = characters[index]
            if quoteCharacters.contains(c) {return}
            cellContents.append(c)
            index = index.successor()
        }
    }
    
    public func abortParsing() {
        
    }
}
