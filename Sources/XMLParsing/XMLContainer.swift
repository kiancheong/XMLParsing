//
//  XMLContainer.swift
//  XMLParsing
//
//  Created by Jeff Seibert on 5/6/18.
//

import Foundation

/// Simple wrapper class that allows the array to be passed by referenced.
class MutableArrayContainer<T> {
    var values: [T]
    
    init(_ values: [T] = []) {
        self.values = values
    }
    
    var count: Int {
        return self.values.count
    }
    
    func append(_ value: T) {
        self.values.append(value)
    }
    
    subscript(key: Int) -> T {
        get {
            return values[key]
        }
        
        set(newValue) {
            values[key] = newValue
        }
    }
}

/// Simple wrapper class that allows the dictionary to be passed by referenced.
class MutableDictionaryContainer<T> {
    var values: [String: T]
    
    init(_ values: [String: T] = [:]) {
        self.values = values
    }
    
    var array: [T] {
        return Array(self.values.values)
    }
    
    subscript(key: String) -> T? {
        get {
            return values[key]
        }
        
        set(newValue) {
            values[key] = newValue
        }
    }
}

enum XMLEncodingContainer {
    case null
    case array(MutableArrayContainer<XMLEncodingContainer>)
    case dictionary(MutableDictionaryContainer<XMLEncodingContainer>)
    case string(String)
    
    case bool(Bool)
    case int(Int)
    case int8(Int8)
    case int16(Int16)
    case int32(Int32)
    case int64(Int64)
    case uint(UInt)
    case uint8(UInt8)
    case uint16(UInt16)
    case uint32(UInt32)
    case uint64(UInt64)
    
    case float(Float)
    case double(Double)
    case decimal(Decimal)
}

enum XMLDecodingContainer: CustomStringConvertible {
    case null
    case array(MutableArrayContainer<XMLDecodingContainer>)
    case dictionary(MutableDictionaryContainer<XMLDecodingContainer>)
    case string(String)
    
    var description: String {
        switch self {
        case .null:
            return "NULL"
        case .array(let array):
            return "[\n\(array.values)\n]"
        case .dictionary(let dictionary):
            return "{\n\(dictionary.values)\n}"
        case .string(let string):
            return string
        }
    }
}
