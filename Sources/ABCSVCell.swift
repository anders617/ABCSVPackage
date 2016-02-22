import Foundation

public enum ABCSVCell:CustomStringConvertible {
    
    case Header(contents:String)
    case Text(contents:String)
    case Integer(contents:Int)
    case Decimal(contents:Double)
    case Date(contents:NSDate)
    case Empty
    
    public init(string:String) {
        //TODO:Better date parsing
        let cleanString = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if cleanString.isEmpty {self = .Empty}
        else if let date = NSDateFormatter().dateFromString(cleanString) {self = .Date(contents: date)}
        else if let integer = Int(cleanString) {self = .Integer(contents: integer)}
        else if let decimal = Double(cleanString) {self = .Decimal(contents: decimal)}
        else if cleanString.characters.count > 0 {self = .Text(contents: cleanString)}
        else {self = .Empty}
    }
    
    public var description:String {
        switch self {
        case .Header(let header): return header
        case .Text(let text): return text
        case .Integer(let integer):return integer.description
        case .Decimal(let decimal):return decimal.description
        case .Date(let date): return date.description
        case Empty: return ""
        }
    }
    
    public var typeDescription:String {
        switch self {
        case .Header(_): return "Header"
        case .Text(_): return "Text"
        case .Integer(_): return "Integer"
        case .Decimal(_): return "Decimal"
        case .Date(_): return "Date"
        case .Empty: return "Empty"
        }
    }
    
    public var value:Any? {
        switch self {
        case .Header(let header): return header
        case .Text(let text): return text
        case .Integer(let integer):return integer
        case .Decimal(let decimal):return decimal
        case .Date(let date): return date
        case Empty: return nil
        }
    }
    
    public var header:ABCSVCell {
        return .Header(contents: self.description)
    }
    
    public var isHeader:Bool {
        switch self {
        case .Header(_): return true
        default: return false
        }
    }
}

extension ABCSVCell: IntegerLiteralConvertible {
    public typealias IntegerLiteralType = Int
    
    public init(integerLiteral value: IntegerLiteralType) {
        self = .Integer(contents: value)
    }
}

extension ABCSVCell: FloatLiteralConvertible {
    public typealias FloatLiteralType = Double
    
    public init(floatLiteral value: FloatLiteralType) {
        self = .Decimal(contents: value)
    }
}

extension ABCSVCell: StringLiteralConvertible {
    public typealias StringLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    public typealias UnicodeScalarLiteralType = Character
    
    public init(stringLiteral value: StringLiteralType) {
        self = .Text(contents: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self = .Text(contents: value)
    }
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = .Text(contents: String(value))
    }
}

extension ABCSVCell: NilLiteralConvertible {
    public init(nilLiteral: ()) {
        self = .Empty
    }
}

extension ABCSVCell: Equatable {}

@warn_unused_result public func ==(lhs:ABCSVCell,rhs:ABCSVCell) -> Bool {
    switch (lhs, rhs) {
    case (.Header(let lhsContent), .Header(let rhsContent)): return lhsContent==rhsContent
    case (.Text(let lhsContent), .Text(let rhsContent)): return lhsContent==rhsContent
    case (.Integer(let lhsContent), .Integer(let rhsContent)): return lhsContent==rhsContent
    case (.Decimal(let lhsContent), .Decimal(let rhsContent)): return lhsContent==rhsContent
    case (.Date(let lhsContent), .Date(let rhsContent)): return lhsContent==rhsContent
    case (.Empty, .Empty): return true
    default: return false
    }
}




