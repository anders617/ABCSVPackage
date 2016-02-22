//
//  PatternMatching.swift
//  ABCSV
//
//  Created by Anders Boberg on 2/20/16.
//  Copyright © 2016 Anders boberg. All rights reserved.
//

import Foundation

/**
 Allows Characters to be pattern matched with collections of Characters. Useful for switch statements.
*/
func ~=<T:CollectionType where T.Generator.Element == Character>(pattern:T, value:Character) -> Bool {
    return pattern.contains(value)
}