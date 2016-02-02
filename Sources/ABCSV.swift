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
    
    private static let defaultValueSeparator = ","
    private static let defaultRowSeparator = "\n"
    
    public var valueSeparator:String
    public var rowSeparator:String
    
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
    
    public static func fromFile(
        file:NSURL,
        withValueSeparator valueSeparator:String = ABCSV.defaultValueSeparator,
        withRowSeparator rowSeparator:String = ABCSV.defaultRowSeparator) -> [ABCSV] {
            do {
                let text = try String(contentsOfURL: file, encoding: NSUTF8StringEncoding)
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
    
    private enum Regex:String {
        case CSV = "(?:(?:[^\n,]+,)+[^\n]+\n?)+"
    }
}