
//
//  XMLEncodingStorage.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/22/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

// MARK: - Encoding Storage and Containers

class MutableXMLContainerArray {
    var values = Array<XMLContainer>()
    
    func append(_ value: XMLContainer) {
        self.values.append(value)
    }
}

class MutableXMLContainerDictionary {
    var values = Dictionary<String, XMLContainer>()
    
    subscript(key: String) -> XMLContainer? {
        get {
            return values[key]
        }
        
        set(newValue) {
            values[key] = newValue
        }
    }
}

enum XMLContainer {
    case null
    case array(MutableXMLContainerArray)
    case dictionary(MutableXMLContainerDictionary)
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

internal struct _XMLEncodingStorage {
    // MARK: Properties
    
    /// The container stack.
    private(set) internal var containers: [XMLContainer] = []
    
    // MARK: - Initialization
    
    /// Initializes `self` with no containers.
    internal init() {}
    
    // MARK: - Modifying the Stack
    
    internal var count: Int {
        return self.containers.count
    }
    
    internal mutating func pushKeyedContainer() -> MutableXMLContainerDictionary {
        let dictionary = MutableXMLContainerDictionary()
        self.containers.append(.dictionary(dictionary))
        return dictionary
    }
    
    internal mutating func pushUnkeyedContainer() -> MutableXMLContainerArray {
        let array = MutableXMLContainerArray()
        self.containers.append(.array(array))
        return array
    }
    
    internal mutating func push(container: XMLContainer) {
        self.containers.append(container)
    }
    
    internal mutating func popContainer() -> XMLContainer {
        precondition(self.containers.count > 0, "Empty container stack.")
        return self.containers.popLast()!
    }
}
