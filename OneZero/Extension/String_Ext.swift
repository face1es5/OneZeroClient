//
//  String_Ext.swift
//  OneZero
//
//  Created by Fish on 15/8/2024.
//

import Foundation

extension URL {
    func urlDecode() -> String {
        return self.path(percentEncoded: false)
    }
}

extension String {
    func urlEncode() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}

extension Int64 {
    func formattedFileSize() -> String {
        let bytes = Double(self)
        let kilobytes = bytes / 1_024
        let megabytes = kilobytes / 1_024
        let gigabytes = megabytes / 1_024
        
        switch bytes {
        case 0..<1_024:
            return "\(Int(bytes)) Bytes"
        case 1_024..<1_048_576:
            return String(format: "%.2f KB", kilobytes)
        case 1_048_576..<1_073_741_824:
            return String(format: "%.2f MB", megabytes)
        default:
            return String(format: "%.2f GB", gigabytes)
        }
    }}

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
