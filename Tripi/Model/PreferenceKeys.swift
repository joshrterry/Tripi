//
//  PreferenceKeys.swift
//  DesignCodeiOS15
//
//  Created by Joshua Terry on 2022-02-05.
//

import SwiftUI

struct ScrollPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
