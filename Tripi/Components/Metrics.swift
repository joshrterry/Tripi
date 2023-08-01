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
    @State var value: Double = 1.2
    
    var body: some View {
        // design for metrics component as seen in SummaryStats and DetailView
        VStack(alignment: .leading) {
            Text(data)
                .font(.custom("Gilroy", size: 40))
                .foregroundColor(color)
            RollingText(font: .custom("Gilroy", size: 40), weight: .black, value: $value)
            Text(descriptor.uppercased())
                .font(.custom("Gilroy", size: 13))
                .opacity(0.4)
        }
    }
}
