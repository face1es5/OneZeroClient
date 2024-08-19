//
//  Form_Ext.swift
//  OneZero
//
//  Created by Fish on 20/8/2024.
//

import SwiftUI

struct Field: View {
    let key: String,
        value: String
    var body: some View {
        Text(NSLocalizedString(key, comment: "") + ": " + NSLocalizedString(value, comment: ""))
            .multilineTextAlignment(.leading)
    }
}

extension Form {
    func field(key: String, value: String) -> some View {
        self.overlay(Field(key: key, value: value))
    }
}
