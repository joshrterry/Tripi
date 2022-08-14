//
//  AnimatableFontModifier.swift
//  DesignCodeiOS15
//
//  Created by Joshua Terry on 2022-02-05.
//

import SwiftUI

struct AnimatableFontModifier: AnimatableModifier {
    var size: Double
    
    var animatableData: Double {
        get { size }
        set { size = newValue }
    }

    func body(content: Content) -> some View {
        content
            .font(.custom("Gilroy", size: size))
    }
}

extension View {
    func animatableFont(size: Double) -> some View {
        self.modifier(AnimatableFontModifier(size: size))
    }
}
