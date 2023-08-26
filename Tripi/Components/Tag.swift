//
//  Tag.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-11-16.
//

import SwiftUI

struct Tag: View {
    @State var name = ""
    @State var colour = Color(red: 0, green: 0, blue: 0)
    @State var isSmall = false
    var body: some View {
        // design for tags component
        ZStack {
            Text(name)
                .foregroundColor(.black)
                .font(.custom("Gilroy", size: isSmall ? 12 : 14))
                .padding()
                .frame(height: isSmall ? 22 : 30)
                .background(colour)
                .cornerRadius(30)
        }
    }
}
