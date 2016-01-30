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
    private(set) var content:ABMatrix<ABCSVCell>
    
    private static let DEFAULT_VALUE_SEPARATOR = ","
    private static let DEFAULT_ROW_SEPARATOR = "\n"
    
    public var valueSeparator:String
    public var rowSeparator:String
    
    public init(rowCount: Int = 1,
        columnCount: Int = 1,
        withValue value:ABCSVCell = .Empty,
        withValueSeparator valueSeparator:String = ABCSV.DEFAULT_VALUE_SEPARATOR,
        withRowSeparator rowSeparator:String = ABCSV.DEFAULT_ROW_SEPARATOR){
            self.valueSeparator = valueSeparator
            self.rowSeparator = rowSeparator
            content = ABMatrix(rowCount: rowCount, columnCount: columnCount, withValue: value)
    }
    
    public convenience init(withHeaders headers: ABVector<ABCSVCell>, rowCount:Int = 1){
        self.init(rowCount:rowCount, columnCount: headers.count)
        for columnNum in 0..<headers.count {content[0,columnNum] = headers[columnNum].header}
    }
    
    public convenience init(fromString string:String,
        withValueSeparator valueSeparator:String = ABCSV.DEFAULT_VALUE_SEPARATOR,
        withRowSeparator rowSeparator: String = ABCSV.DEFAULT_ROW_SEPARATOR) {
            let rows = string.componentsSeparatedByString(rowSeparator)
            let csv = rows
                .map{$0.componentsSeparatedByString(valueSeparator)}
                .map{$0.map{ABCSVCell(string: $0)}}
            self.init(rowCount:csv.count,
                columnCount: csv.maxElement{$0.count < $1.count}!.count,
                withValueSeparator: valueSeparator,
                withRowSeparator: rowSeparator)
            for rowNum in 0..<csv.count {
                for colNum in 0..<csv[rowNum].count {
                    self[rowNum,colNum] = csv[rowNum][colNum]
                }
            }
    }
    
    public convenience init(fromMatrix matrix: ABMatrix<ABCSVCell>,
        withValueSeparator valueSeparator:String = ABCSV.DEFAULT_VALUE_SEPARATOR,
        withRowSeparator rowSeparator:String = ABCSV.DEFAULT_ROW_SEPARATOR) {
            self.init(rowCount:matrix.rowCount,
                columnCount:matrix.columnCount,
                withValueSeparator: valueSeparator,
                withRowSeparator:rowSeparator)
            let rowGenerator = matrix.row
            for rowNum in 0..<matrix.rowCount {
                self.insertRow(rowGenerator[rowNum], atIndex: rowNum)
            }
    }
    
    public static func fromText(text:String,
        range:Range<String.Index>?,
        withValueSeparator valueSeparator:String = ABCSV.DEFAULT_VALUE_SEPARATOR,
        withRowSeparator rowSeparator:String = ABCSV.DEFAULT_ROW_SEPARATOR) -> [ABCSV] {
            let ranges = text.rangesOfString(Regex.CSV.rawValue,
                options: .RegularExpressionSearch,
                range: range,
                locale: nil)
            var csvs:[ABCSV] = []
            for range in ranges {
                csvs += [
                    ABCSV(fromString: text[range].stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet()))
                ]
            }
            return csvs
    }
    
    public var description:String {
        return content.description
    }
    
    public var stringRepresentation:String {
        var string = ""
        for rowNum in 0..<content.rowCount {
            for columnNum in 0..<content.columnCount-1 {
                string += "\(content[rowNum, columnNum].description)\(valueSeparator)"
            }
            string += "\(content[rowNum, content.columnCount-1])"
            string += rowSeparator
        }
        return string
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
    
    public func insertColumn(column: ABVector<ABCSVCell>, atIndex index:Int) {
        content.insertColumn(column, atColumnIndex: index)
    }
    
    public func removeColumnAtIndex(index:Int) {
        content.removeColumn(index)
    }
    
    public func appendColumn(column: ABVector<ABCSVCell>) {
        content.appendColumn(column)
    }
    
    public func insertRow(row: ABVector<ABCSVCell>, atIndex index:Int) {
        content.insertRow(row, atRowIndex: index)
    }
    
    public func removeRowAtIndex(index:Int) {
        content.removeRow(index)
    }
    
    public func appendRow(row: ABVector<ABCSVCell>) {
        content.appendRow(row)
    }
    
    private enum Regex:String {
        case CSV = "(?:(?:[^\n,]+,)+[^\n]+\n?)+"
    }
}