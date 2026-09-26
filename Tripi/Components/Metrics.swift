//
//  Metric.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-01.
//

import SwiftUI

struct Metric: View {
    var data = ""
    var descriptor = ""
    var color = Color.primary
    
    var body: some View {
        // design for metrics component as seen in SummaryStats and DetailView
        VStack(alignment: .leading) {
            // full-size placeholder sets a constant line height; the value is laid out inside that space,
            // so it only scales down when too wide and the label below never moves
            Text("0")
                .font(.custom("Gilroy", size: 40))
                .hidden()
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .bottomLeading) {
                    Text(data)
                        .font(.custom("Gilroy", size: 40))
                        .monospacedDigit() // tabular figures so values don't jitter as digits change
                        .lineLimit(1)
                        .minimumScaleFactor(0.5) // shrink unusually large values rather than wrapping or truncating
                        .foregroundColor(color)
                        .contentTransition(.numericText()) // digits roll when the value changes
                        .animation(.snappy, value: data)
                }
            Text(descriptor.uppercased())
                .font(.custom("Gilroy", size: 13))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .opacity(0.4)
        }
        // fill the column the caller gives it, pinned to the leading edge so the label never moves
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
