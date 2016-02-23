//
//  ABCSVCollector.swift
//  ABCSV
//
//  Created by Anders Boberg on 2/23/16.
//  Copyright © 2016 Anders boberg. All rights reserved.
//
import ABMatrices

struct ABCSVParserCollector:ABCSVParserDelegate {
    private(set) var contents:ABMatrix<ABCSVCell> = ABMatrix(rowCount: 1, columnCount: 1, withValue: nil)
    private var currentRow:ABVector<ABCSVCell> = [nil]
    var callback:((ABCSVParserCollector)->())?
    
    mutating func csvParserDidStartDocument() {
        currentRow = [nil]
    }
    
    mutating func csvParser(parser: ABCSVParser, didStartRow row: Int) {
        
    }
    
    mutating func csvParser(parser:ABCSVParser, didEndRow row:Int, columnCount:Int) {
        if row == 0 {
            contents = ABMatrix(rowCount: 1, columnCount: columnCount, withValue: nil)
            contents[0] = currentRow
        } else {
            if currentRow.count == contents.columnCount {
                contents.appendRow(currentRow)
            }
        }
        currentRow = [nil]
    }
    
    mutating func csvParser(parser: ABCSVParser, foundCell contents: String, row: Int, column: Int) {
        if column == 0 {
            currentRow[0] = ABCSVCell(string:contents)
        } else {
            currentRow.append(ABCSVCell(string: contents))
        }
    }
    
    mutating func csvParserDidEndDocument() {
        if contents.lastRow.allEqual(.Empty) {
            contents.removeRow(contents.rowCount-1)
        }
        if contents.firstRow.allEqual(.Empty) {
            contents.removeRow(0)
        }
        if let end = callback {
            end(self)
        }
    }
}