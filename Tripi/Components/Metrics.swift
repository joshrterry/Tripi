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
        VStack(alignment: .leading) {
            Text(data)
                .font(.custom("Gilroy", size: 40))
                .foregroundColor(color)
            Text(descriptor.uppercased())
                .font(.custom("Gilroy", size: 13))
                .opacity(0.4)
        }
    }
}

struct Metric_Previews: PreviewProvider {
    static var previews: some View {
        Metric(data: "313.2", descriptor: "total km")
    }
}
