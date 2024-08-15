//
//  String_Ext.swift
//  OneZero
//
//  Created by Fish on 15/8/2024.
//

import Foundation

extension String {
    func urlEncode() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}

/**
 Extends Data to support append string directly(automately encode string into utf8).
 */
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
