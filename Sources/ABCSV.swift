//
//  ABCSV.swift
//  ABCSV
//
//  Created by Anders Boberg on 1/9/16.
//  Copyright © 2016 Anders boberg. All rights reserved.
//

import Foundation
import ABMatrices


public class ABCSV:CustomStringConvertible {
    public enum ABCSVQuotingRule {
        case AllFields
        case AllTextFields
        case NecessaryTextFields
        case None
    }
    
    private(set) var content:ABMatrix<ABCSVCell>
    
    private static let defaultValueSeparator = ","
    private static let defaultRowSeparator = "\n"
    
    public var valueSeparator:String
    public var rowSeparator:String
    public var quotingRule:ABCSVQuotingRule = .NecessaryTextFields
    
    public var columnCount:Int {
        return content.columnCount
    }
    
    public var rowCount:Int {
        return content.rowCount
    }
    
    public init(
        rowCount: Int = 1,
        columnCount: Int = 1,
        withValue value:ABCSVCell = .Empty,
        withValueSeparator valueSeparator:String = ABCSV.defaultValueSeparator,
        withRowSeparator rowSeparator:String = ABCSV.defaultRowSeparator){
            self.valueSeparator = valueSeparator
            self.rowSeparator = rowSeparator
            content = ABMatrix(rowCount: rowCount, columnCount: columnCount, withValue: value)
    }
    
    public convenience init(withHeaders headers: ABVector<ABCSVCell>, rowCount:Int = 1){
        self.init(rowCount:rowCount, columnCount: headers.count)
        for columnNum in 0..<headers.count {content[0,columnNum] = headers[columnNum].header}
    }
    
    public convenience init(
        fromString string:String,
        withValueSeparator valueSeparator:String = ABCSV.defaultValueSeparator,
        withRowSeparator rowSeparator: String = ABCSV.defaultRowSeparator) {
            let waitSemaphore = dispatch_semaphore_create(0)
            var collector = ABCSVParserCollector()
            var matrix:ABMatrix<ABCSVCell> = [[nil]]
            collector.callback = {collect in
                matrix = collect.contents
                dispatch_semaphore_signal(waitSemaphore)
            }
            let parser = ABCSVParser(contents: string)
            parser.delegate = collector
            parser.parse()
            dispatch_semaphore_wait(waitSemaphore, DISPATCH_TIME_FOREVER)//Ensure callback completion
            self.init(fromMatrix:matrix)
    }
    
    public convenience init(
        fromMatrix matrix: ABMatrix<ABCSVCell>,
        withValueSeparator valueSeparator:String = ABCSV.defaultValueSeparator,
        withRowSeparator rowSeparator:String = ABCSV.defaultRowSeparator) {
            self.init(rowCount:matrix.rowCount,
                columnCount:matrix.columnCount,
                withValueSeparator: valueSeparator,
                withRowSeparator:rowSeparator)
            content = matrix
    }
    
    public static func fromText(
        text:String,
        range:Range<String.Index>?,
        withValueSeparator valueSeparator:String = ABCSV.defaultValueSeparator,
        withRowSeparator rowSeparator:String = ABCSV.defaultRowSeparator) -> [ABCSV] {
            let ranges = text.rangesOfString(Regex.CSV(val: valueSeparator, row: rowSeparator).expression,
                options: .RegularExpressionSearch,
                range: range,
                locale: nil)
            var csvs:[ABCSV] = []
            for range in ranges {
                csvs += [
                    ABCSV(fromString: text[range])
                ]
            }
            return csvs
    }
    
    public static func fromFile(
        file:NSURL,
        withValueSeparator valueSeparator:String = ABCSV.defaultValueSeparator,
        withRowSeparator rowSeparator:String = ABCSV.defaultRowSeparator) -> [ABCSV] {
            do {
                let text = try String(contentsOfURL: file)
                return ABCSV.fromText(text, range: nil)
            } catch {
                print(error)
                return []
            }
    }
    
    public static func fromFile(
        path:String,
        withValueSeparator valueSeparator:String = ABCSV.defaultValueSeparator,
        withRowSeparator rowSeparator:String = ABCSV.defaultRowSeparator) -> [ABCSV] {
            let file = NSURL(fileURLWithPath: path)
            return ABCSV.fromFile(file)
    }
    
    public var description:String {
        return content.description
    }
    
    public var stringRepresentation:String {
        var string = ""
        for rowNum in 0..<content.rowCount {
            for columnNum in 0..<content.columnCount-1 {
                string += "\(applyQuotingRuleToCell(content[rowNum, columnNum]))\(valueSeparator)"
            }
            string += "\(content[rowNum, content.columnCount-1])"
            string += rowSeparator
        }
        return string
    }
    
    private func applyQuotingRuleToCell(cell:ABCSVCell) -> String {
        switch quotingRule {
        case .AllFields:
            return "\"\(cell.description)\""
        case .AllTextFields:
            if cell.isText {return "\"\(cell.description)\""}
            return cell.description
        case .NecessaryTextFields:
            let desc = cell.description
            if cell.isText && (desc.containsString(rowSeparator)||desc.containsString(valueSeparator)) {
                return "\"\(desc)\""
            }
            return cell.description
        case .None: return cell.description
        }
    }
    
    public var dataRepresentation:NSData? {
        return stringRepresentation.dataUsingEncoding(NSUnicodeStringEncoding)
    }
    
    public subscript(row:Int, column:Int) -> ABCSVCell {
        get {
            return content[row, column]
        }
        set {
            content[row, column] = newValue
        }
    }
    
    public subscript(row:Int) -> ABVector<ABCSVCell> {
        get {
            return content[row]
        }
        set {
            content[row] = newValue
        }
    }
    
    public func column(columnNum:Int) -> ABVector<ABCSVCell> {
        return content.column(columnNum)
    }
    
    public func swapColumns(first:Int,_ second:Int) {
        let temp = content.column(first)
        content.setColumn(content.column(second), atIndex: first)
        content.setColumn(temp, atIndex: second)
    }
    
    public func setColumn(newColumn: ABVector<ABCSVCell>, atIndex columnNum:Int) {
        content.setColumn(newColumn, atIndex: columnNum)
    }
    
    public func setRow(newRow: ABVector<ABCSVCell>, atIndex rowNum:Int) {
        content.setRow(newRow, atIndex: rowNum)
    }
    
    public func insertColumn(newColumn: ABVector<ABCSVCell>, atIndex columnNum:Int) {
        content.insertColumn(newColumn, atIndex: columnNum)
    }
    
    public func removeColumnAtIndex(index:Int) {
        content.removeColumn(index)
    }
    
    public func appendColumn(column: ABVector<ABCSVCell>) {
        content.appendColumn(column)
    }
    
    public func row(rowNum:Int) -> ABVector<ABCSVCell> {
        return content.row(rowNum)
    }
    
    public func swapRows(first:Int,_ second:Int) {
        let temp = content.row(first)
        content.setRow(content.row(second), atIndex: first)
        content.setRow(temp, atIndex: second)
    }
    
    public func insertRow(newRow: ABVector<ABCSVCell>, atIndex rowNum:Int) {
        content.insertRow(newRow, atIndex: rowNum)
    }
    
    public func removeRowAtIndex(index:Int) {
        content.removeRow(index)
    }
    
    public func appendRow(row: ABVector<ABCSVCell>) {
        content.appendRow(row)
    }
    
    private enum Regex {
        case CSV(val:String, row:String) //= //"(?:(?:[^\n,]+,)+[^\n]+\n?)+"
        case Cell(val:String, row:String)
        case Row(row:String)
        case QuotedText //= //"(?:\".*)(,)(?=.*\")"
        
        var expression:String {
            switch self {
            case let .CSV(valueSeparator, rowSeparator):
                return "(?:(?:[^\(rowSeparator)\(valueSeparator)]+\(valueSeparator))+[^\(rowSeparator)]+\(rowSeparator)?)+"
            case let .Cell(valueSeparator, rowSeparator):
                return "[^\(valueSeparator)\(rowSeparator)]+"
            case let .Row(rowSeparator):
                return "[^\(rowSeparator)]+\(rowSeparator)?"
            case .QuotedText:
                return "\"[^\"]*\""
            }
        }
    }
}

extension ABCSV: ABCSVParserDelegate {
    public func csvParserDidStartDocument() {
        
    }
    
    public func csvParser(parser: ABCSVParser, didStartRow row: Int) {
        
    }
    
    public func csvParser(parser:ABCSVParser, didEndRow row:Int, columnCount:Int) {
        
    }
    
    public func csvParser(parser: ABCSVParser, foundCell contents: String, row: Int, column: Int) {
        
    }
    
    public func csvParserDidEndDocument() {
        
    }
}

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
        if let end = callback {
            end(self)
        }
    }
}

