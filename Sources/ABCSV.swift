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
    
    public var valueSeparator = ","
    public var rowSeparator = "\n"
    
    public init() {
        content = ABMatrix(rowCount: 1, columnCount: 1, withValue: .Empty)
    }
    
    public init(rowCount: Int, columnCount: Int, withValue value:ABCSVCell = .Empty) {
        content = ABMatrix(rowCount: rowCount, columnCount: columnCount, withValue: value)
    }
    
    public init(withHeaders headers: ABVector<ABCSVCell>) {
        content = ABMatrix(rowCount: 1, columnCount: headers.count, withValue: .Empty)
        for columnNum in 0..<headers.count {content[0,columnNum] = headers[columnNum].header}
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
        content.removeColumnAtColumnIndex(index)
    }
    
    public func appendColumn(column: ABVector<ABCSVCell>) {
        content.appendColumn(column)
    }
    
    public func insertRow(row: ABVector<ABCSVCell>, atIndex index:Int) {
        content.insertRow(row, atRowIndex: index)
    }
    
    public func removeRowAtIndex(index:Int) {
        content.removeRowAtRowIndex(index)
    }
    
    public func appendRow(row: ABVector<ABCSVCell>) {
        content.appendRow(row)
    }
}