//
//  BackButton.swift
//  Tripi
//
//  Created by Joshua Terry on 2023-01-12.
//

import SwiftUI

// button for closing TripDetailView
struct BackButton: View {
    let dismiss: DismissAction
    
    var body: some View {
        // dismisses current view that is open
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.body.weight(.bold))
                .frame(width: 40, height: 40)
                .foregroundColor(.secondary)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .strokeStyle(cornerRadius: 14)
        }
    }
}
