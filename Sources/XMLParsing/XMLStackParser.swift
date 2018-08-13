//
//  XMLStackParser.swift
//  CustomEncoder
//
//  Created by Shawn Moore on 11/14/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

//===----------------------------------------------------------------------===//
// Data Representation
//===----------------------------------------------------------------------===//

public struct XMLHeader {
    /// the XML standard that the produced document conforms to.
    var version: Double? = nil
    /// the encoding standard used to represent the characters in the produced document.
    var encoding: String? = nil
    /// indicates whetehr a document relies on information from an external source.
    var standalone: String? = nil
    
    public init(version: Double? = nil) {
        self.version = version
    }
    
    public init(version: Double?, encoding: String?, standalone: String? = nil) {
        self.version = version
        self.encoding = encoding
        self.standalone = standalone
    }
    
    internal func isEmpty() -> Bool {
        return version == nil && encoding == nil && standalone == nil
    }
    
    internal func toXML() -> String? {
        guard !self.isEmpty() else { return nil }
        
        var string = "<?xml "
        
        if let version = version {
            string += "version=\"\(version)\" "
        }
        
        if let encoding = encoding {
            string += "encoding=\"\(encoding)\" "
        }
        
        if let standalone = standalone {
            string += "standalone=\"\(standalone)\""
        }
        
        return string.trimmingCharacters(in: .whitespaces) + "?>\n"
    }
}

internal class _XMLElement {
    static let attributesKey = "___ATTRIBUTES"
    static let escapedCharacterSet = [("&", "&amp"), ("<", "&lt;"), (">", "&gt;"), ( "'", "&apos;"), ("\"", "&quot;")]
    
    var key: String
    var value: String? = nil
    var attributes: [String: String] = [:]
    var children: [String: [_XMLElement]] = [:]
    
    internal init(key: String, value: String? = nil, attributes: [String: String] = [:], children: [String: [_XMLElement]] = [:]) {
        self.key = key
        self.value = value
        self.attributes = attributes
        self.children = children
    }
    
    convenience init(key: String, value: Optional<CustomStringConvertible>, attributes: [String: CustomStringConvertible] = [:]) {
        self.init(key: key, value: value?.description, attributes: attributes.mapValues({ $0.description }), children: [:])
    }
    
    convenience init(key: String, children: [String: [_XMLElement]], attributes: [String: CustomStringConvertible] = [:]) {
        self.init(key: key, value: nil, attributes: attributes.mapValues({ $0.description }), children: children)
    }
    
    static func createRootElement(_ container: XMLEncodingContainer, rootKey: String) -> _XMLElement? {
        let element = _XMLElement(key: rootKey)
        
        switch container {
        case .dictionary(let dictionary):
            _XMLElement.modifyElement(element: element, parentElement: nil, key: nil, dictionary: dictionary)
        case .array(_):
            _XMLElement.createElement(container, parent: element, key: rootKey)
        default:
            return nil
        }
        
        return element
    }
    
    fileprivate static func modifyElement(element: _XMLElement,
                                          parentElement: _XMLElement?,
                                          key: String?,
                                          dictionary: MutableDictionaryContainer<XMLEncodingContainer>) {
        let attributes = dictionary.values[_XMLElement.attributesKey] ?? .null
        switch attributes {
        case .dictionary(let attributesDictionary):
            element.attributes = attributesDictionary.values.mapValues { String(describing: $0) }
        default:
            element.attributes = [:]
        }
        
        for (key, value) in dictionary.values {
            guard key != _XMLElement.attributesKey else {
                continue
            }
            
            self.createElement(value, parent: element, key: key)
        }
        
        if let parentElement = parentElement, let key = key {
            parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
        }
    }
    
    fileprivate static func createElement(_ container: XMLEncodingContainer, parent parentElement: _XMLElement, key: String) {
        switch container {
        case .null:
            let element = _XMLElement(key: key)
            parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
            
        case .array(let mutable):
            mutable.values.forEach { value in
                self.createElement(value, parent: parentElement, key: key)
            }
        
        case .dictionary(let dictionary):
            let element = _XMLElement(key: key)
            self.modifyElement(element: element, parentElement: parentElement, key: key, dictionary: dictionary)
        
        case .string(let value):
            let element = _XMLElement(key: key, value: value.description)
            parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
        case .bool(let value):
            let element = _XMLElement(key: key, value: value.description)
            parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
        case .int(let value):
            let element = _XMLElement(key: key, value: value.description)
            parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
        case .int8(let value):
            let element = _XMLElement(key: key, value: value.description)
            parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
        case .int16(let value):
            let element = _XMLElement(key: key, value: value.description)
            parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
        case .int32(let value):
            let element = _XMLElement(key: key, value: value.description)
            parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
        case .int64(let value):
            let element = _XMLElement(key: key, value: value.description)
            parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
        case .uint(let value):
            let element = _XMLElement(key: key, value: value.description)
            parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
        case .uint8(let value):
            let element = _XMLElement(key: key, value: value.description)
            parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
        case .uint16(let value):
            let element = _XMLElement(key: key, value: value.description)
            parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
        case .uint32(let value):
            let element = _XMLElement(key: key, value: value.description)
            parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
        case .uint64(let value):
            let element = _XMLElement(key: key, value: value.description)
            parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
        case .float(let value):
            let element = _XMLElement(key: key, value: value.description)
            parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
        case .double(let value):
            let element = _XMLElement(key: key, value: value.description)
            parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
        case .decimal(let value):
            let element = _XMLElement(key: key, value: value.description)
            parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
        }
    }
    
    func flatten() -> XMLDecodingContainer {
        let node = MutableDictionaryContainer(attributes.mapValues { XMLDecodingContainer.string($0) })
        
        for childElement in children {
            for child in childElement.value {
                if let content = child.value {
                    node[childElement.key] = .string(content)
                } else if !child.children.isEmpty || !child.attributes.isEmpty {
                    let newValue = child.flatten()
                    
                    if let existingValue = node[childElement.key] {
                        switch existingValue {
                        case .array(let array):
                            array.append(newValue)
                        default:
                            node[childElement.key] = .array(MutableArrayContainer([existingValue, newValue]))
                        }
                    } else {
                        node[childElement.key] = newValue
                    }
                }
            }
        }
        
        return .dictionary(node)
    }
    
    func toXMLString(with header: XMLHeader? = nil, withCDATA cdata: Bool, ignoreEscaping: Bool = false, outputFormatting: XMLEncoder.OutputFormatting = []) -> String {
        if let header = header, let headerXML = header.toXML() {
            return headerXML + _toXMLString(withCDATA: cdata, ignoreEscaping: ignoreEscaping, outputFormatting: outputFormatting)
        } else {
            return _toXMLString(withCDATA: cdata, ignoreEscaping: ignoreEscaping, outputFormatting: outputFormatting)
        }
    }
    
    fileprivate func _toXMLString(indented level: Int = 0, withCDATA cdata: Bool, ignoreEscaping: Bool = false, outputFormatting: XMLEncoder.OutputFormatting = []) -> String {
        var string = ""
        if outputFormatting.contains(.prettyPrinted) {
            string += String(repeating: " ", count: level * 4)
        }
        string += "<\(key)"
        
        for (key, value) in attributes {
            string += " \(key)=\"\(value.escape(_XMLElement.escapedCharacterSet))\""
        }
        
        if let value = value {
            string += ">"
            if !ignoreEscaping {
                string += (cdata == true ? "<![CDATA[\(value)]]>" : "\(value.escape(_XMLElement.escapedCharacterSet))" )
            } else {
                string += "\(value)"
            }
            string += "</\(key)>"
        } else if !children.isEmpty {
            string += ">"
            if outputFormatting.contains(.prettyPrinted) {
                string += "\n"
            }

            let childElements: [[_XMLElement]]
            if outputFormatting.contains(.sortedKeys) {
                childElements = children.sorted { $0.key < $1.key } .map { $0.value }
            } else {
                childElements = Array(children.values)
            }
            
            for childElement in childElements {
                for child in childElement {
                    string += child._toXMLString(indented: level + 1, withCDATA: cdata, ignoreEscaping: ignoreEscaping, outputFormatting: outputFormatting)
                    if outputFormatting.contains(.prettyPrinted) {
                        string += "\n"
                    }
                }
            }

            if outputFormatting.contains(.prettyPrinted) {
                string += String(repeating: " ", count: level * 4)
            }
            string += "</\(key)>"
        } else {
            string += " />"
        }
        
        return string
    }
}

extension String {
    func escape(_ characterSet: [(character: String, escapedCharacter: String)]) -> String {
        var string = self
        
        for set in characterSet {
            string = string.replacingOccurrences(of: set.character, with: set.escapedCharacter, options: .literal)
        }
        
        return string
    }
}

internal class _XMLStackParser: NSObject, XMLParserDelegate {
    var root: _XMLElement?
    var stack = [_XMLElement]()
    var currentNode: _XMLElement?
    
    var currentElementName: String?
    var currentElementData = ""
    
    static func parse(with data: Data) throws -> XMLDecodingContainer {
        let parser = _XMLStackParser()
        
        do {
            if let node = try parser.parse(with: data) {
                return node.flatten()
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data could not be parsed into XML."))
            }
        } catch {
            throw error
        }
    }
    
    func parse(with data: Data) throws -> _XMLElement?  {
        let xmlParser = XMLParser(data: data)
        xmlParser.delegate = self
        
        if xmlParser.parse() {
            return root
        } else if let error = xmlParser.parserError {
            throw error
        } else {
            return nil
        }
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        root = nil
        stack = [_XMLElement]()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        let node = _XMLElement(key: elementName)
        node.attributes = attributeDict
        stack.append(node)
        
        if let currentNode = currentNode {
            if currentNode.children[elementName] != nil {
                currentNode.children[elementName]?.append(node)
            } else {
                currentNode.children[elementName] = [node]
            }
        }
        currentNode = node
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let poppedNode = stack.popLast(){
            if let content = poppedNode.value?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
                if content.isEmpty {
                    poppedNode.value = nil
                } else {
                    poppedNode.value = content
                }
            }
            
            if (stack.isEmpty) {
                root = poppedNode
                currentNode = nil
            } else {
                currentNode = stack.last
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentNode?.value = (currentNode?.value ?? "") + string
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if let string = String(data: CDATABlock, encoding: .utf8) {
            currentNode?.value = (currentNode?.value ?? "") + string
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
    }
}

