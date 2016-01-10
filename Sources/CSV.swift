//
//  CSV.swift
//  ABCSV
//
//  Created by Anders Boberg on 1/9/16.
//  Copyright © 2016 Anders boberg. All rights reserved.
//

import Foundation
import ABMatrices

public class CSV {
    internal(set) var content:ABMatrix<CSVCell>
    
    public init() {
        content = ABMatrix(rowCount: 1, columnCount: 1, withValue: .Empty)
    }
    
    public init(rowCount: Int, columnCount: Int, withValue value:CSVCell = .Empty) {
        content = ABMatrix(rowCount: rowCount, columnCount: columnCount, withValue: value)
    }
    
    public init(withHeaders headers: ABVector<CSVCell>) {
        content = ABMatrix(rowCount: 1, columnCount: headers.count, withValue: .Empty)
        for columnNum in 0..<headers.count {content[0,columnNum] = headers[columnNum].header}
    }
    
}