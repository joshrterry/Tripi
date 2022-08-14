//
//  SummaryStats.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-01.
//

import SwiftUI

struct SummaryStats: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            HStack {
                Text("This Month")
                    .font(.custom("Gilroy", size: 24))
                    .padding(.trailing)
                Text("This Week")
                    .font(.custom("Gilroy", size: 24))
                    .opacity(0.2)
            }
            HStack(spacing: 70) {
                Metric(data: "313.2", descriptor: "total km")
                Metric(data: "102.3", descriptor: "business km")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 70) {
                Metric(data: "8.3", descriptor: "hours driven")
                Metric(data: "$94.32", descriptor: "reimbursable", color: Color.green)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(30)
    }
}

struct SummaryStats_Previews: PreviewProvider {
    static var previews: some View {
        SummaryStats()
    }
}
