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
            Text(data)
                .font(.custom("Gilroy", size: 40))
                .foregroundColor(color)
                .contentTransition(.numericText()) // digits roll when the value changes
                .animation(.snappy, value: data)
            Text(descriptor.uppercased())
                .font(.custom("Gilroy", size: 13))
                .opacity(0.4)
        }
    }
}
