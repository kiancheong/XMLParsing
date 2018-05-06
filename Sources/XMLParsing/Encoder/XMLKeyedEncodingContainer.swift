//
//  XMLKeyedEncodingContainer.swift
//  XMLParsing
//
//  Created by Jeff Seibert on 5/6/18.
//

import Foundation

struct _XMLKeyedEncodingContainer<K : CodingKey> : KeyedEncodingContainerProtocol {
    typealias Key = K
    
    // MARK: Properties
    
    /// A reference to the encoder we're writing to.
    private let encoder: _XMLEncoder
    
    /// A reference to the container we're writing to.
    private let container: MutableDictionaryContainer<XMLEncodingContainer>
    
    /// The path of coding keys taken to get to this point in encoding.
    private(set) public var codingPath: [CodingKey]
    
    // MARK: - Initialization
    
    /// Initializes `self` with the given references.
    init(referencing encoder: _XMLEncoder, codingPath: [CodingKey], wrapping container: MutableDictionaryContainer<XMLEncodingContainer>) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }
    
    // MARK: - Coding Path Operations
    
    private func _converted(_ key: CodingKey) -> CodingKey {
        switch encoder.options.keyEncodingStrategy {
        case .useDefaultKeys:
            return key
        case .convertToSnakeCase:
            let newKeyString = XMLEncoder.KeyEncodingStrategy._convertToSnakeCase(key.stringValue)
            return _XMLKey(stringValue: newKeyString, intValue: key.intValue)
        case .custom(let converter):
            return converter(codingPath + [key])
        }
    }
    
    // MARK: - KeyedEncodingContainerProtocol Methods
    
    public mutating func encodeNil(forKey key: Key) throws {
        self.container[_converted(key).stringValue] = .null
    }
    
    private mutating func _encode(attribute value: XMLEncodingContainer, forKey key: Key) {
        switch self.container[_XMLElement.attributesKey] ?? .null {
        case .dictionary(let dictionary):
            dictionary[_converted(key).stringValue] = value
        default:
            let dictionary = MutableDictionaryContainer<XMLEncodingContainer>()
            dictionary[_converted(key).stringValue] = value
            self.container[_XMLElement.attributesKey] = .dictionary(dictionary)
        }
    }
    
    private mutating func _encode(container: XMLEncodingContainer, forKey key: Key) {
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        
        switch self.encoder.options.attributeEncodingStrategy {
        case .custom(let closure) where closure(self.encoder):
            self._encode(attribute: container, forKey: key)
        default:
            self.container[_converted(key).stringValue] = container
        }
    }
    
    public mutating func encode(_ value: Bool, forKey key: Key) throws {
        self._encode(container: self.encoder.box(value), forKey: key)
    }
    
    public mutating func encode(_ value: Int, forKey key: Key) throws {
        self._encode(container: self.encoder.box(value), forKey: key)
    }
    
    public mutating func encode(_ value: Int8, forKey key: Key) throws {
        self._encode(container: self.encoder.box(value), forKey: key)
    }
    
    public mutating func encode(_ value: Int16, forKey key: Key) throws {
        self._encode(container: self.encoder.box(value), forKey: key)
    }
    
    public mutating func encode(_ value: Int32, forKey key: Key) throws {
        self._encode(container: self.encoder.box(value), forKey: key)
    }
    
    public mutating func encode(_ value: Int64, forKey key: Key) throws {
        self._encode(container: self.encoder.box(value), forKey: key)
    }
    
    public mutating func encode(_ value: UInt, forKey key: Key) throws {
        self._encode(container: self.encoder.box(value), forKey: key)
    }
    
    public mutating func encode(_ value: UInt8, forKey key: Key) throws {
        self._encode(container: self.encoder.box(value), forKey: key)
    }
    
    public mutating func encode(_ value: UInt16, forKey key: Key) throws {
        self._encode(container: self.encoder.box(value), forKey: key)
    }
    
    public mutating func encode(_ value: UInt32, forKey key: Key) throws {
        self._encode(container: self.encoder.box(value), forKey: key)
    }
    
    public mutating func encode(_ value: UInt64, forKey key: Key) throws {
        self._encode(container: self.encoder.box(value), forKey: key)
    }
    
    public mutating func encode(_ value: String, forKey key: Key) throws {
        self._encode(container: self.encoder.box(value), forKey: key)
    }
    
    public mutating func encode(_ value: Float, forKey key: Key) throws {
        // Since the float may be invalid and throw, the coding path needs to contain this key.
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        
        switch self.encoder.options.attributeEncodingStrategy {
        case .custom(let closure) where closure(self.encoder):
            self._encode(attribute: try self.encoder.box(value), forKey: key)
        default:
            self.container[_converted(key).stringValue] = try self.encoder.box(value)
        }
    }
    
    public mutating func encode(_ value: Double, forKey key: Key) throws {
        // Since the double may be invalid and throw, the coding path needs to contain this key.
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        
        switch self.encoder.options.attributeEncodingStrategy {
        case .custom(let closure) where closure(self.encoder):
            self._encode(attribute: try self.encoder.box(value), forKey: key)
        default:
            self.container[_converted(key).stringValue] = try self.encoder.box(value)
        }
    }
    
    public mutating func encode<T : Encodable>(_ value: T, forKey key: Key) throws {
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        
        if T.self == Date.self {
            switch self.encoder.options.attributeEncodingStrategy {
            case .custom(let closure) where closure(self.encoder):
                self._encode(attribute: try self.encoder.box(value), forKey: key)
            default:
                self.container[_converted(key).stringValue] = try self.encoder.box(value)
            }
        } else {
            self.container[_converted(key).stringValue] = try self.encoder.box(value)
        }
    }
    
    public mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        let dictionary = MutableDictionaryContainer<XMLEncodingContainer>()
        self.container[_converted(key).stringValue] = .dictionary(dictionary)
        
        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }
        
        let container = _XMLKeyedEncodingContainer<NestedKey>(referencing: self.encoder, codingPath: self.codingPath, wrapping: dictionary)
        return KeyedEncodingContainer(container)
    }
    
    public mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let array = MutableArrayContainer<XMLEncodingContainer>()
        self.container[_converted(key).stringValue] = .array(array)
        
        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }
        return _XMLUnkeyedEncodingContainer(referencing: self.encoder, codingPath: self.codingPath, wrapping: array)
    }
    
    public mutating func superEncoder() -> Encoder {
        return _XMLReferencingEncoder(referencing: self.encoder, key: _XMLKey.super, convertedKey: _converted(_XMLKey.super), wrapping: self.container)
    }
    
    public mutating func superEncoder(forKey key: Key) -> Encoder {
        return _XMLReferencingEncoder(referencing: self.encoder, key: key, convertedKey: _converted(key), wrapping: self.container)
    }
}
