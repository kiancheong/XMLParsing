
//
//  XMLEncodingStorage.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/22/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

internal struct _XMLEncodingStorage {
    // MARK: Properties
    
    /// The container stack.
    private(set) internal var containers: [XMLEncodingContainer] = []
    
    // MARK: - Initialization
    
    /// Initializes `self` with no containers.
    internal init() {}
    
    // MARK: - Modifying the Stack
    
    internal var count: Int {
        return self.containers.count
    }
    
    internal mutating func pushKeyedContainer() -> MutableDictionaryContainer<XMLEncodingContainer> {
        let dictionary = MutableDictionaryContainer<XMLEncodingContainer>()
        self.containers.append(.dictionary(dictionary))
        return dictionary
    }
    
    internal mutating func pushUnkeyedContainer() -> MutableArrayContainer<XMLEncodingContainer> {
        let array = MutableArrayContainer<XMLEncodingContainer>()
        self.containers.append(.array(array))
        return array
    }
    
    internal mutating func push(container: XMLEncodingContainer) {
        self.containers.append(container)
    }
    
    internal mutating func popContainer() -> XMLEncodingContainer {
        precondition(self.containers.count > 0, "Empty container stack.")
        return self.containers.popLast()!
    }
}
