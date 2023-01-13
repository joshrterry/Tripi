//
//  BackButton.swift
//  Tripi
//
//  Created by Joshua Terry on 2023-01-12.
//

import SwiftUI

struct BackButton: View {
    let dismiss: DismissAction
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.body.weight(.bold))
                .frame(width: 36, height: 36)
                .foregroundColor(.secondary)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .strokeStyle(cornerRadius: 14)
        }
    }
}

//struct BackButton_Previews: PreviewProvider {
//    static var previews: some View {
//        BackButton(dismiss: )
//    }
//}
