//
//  SummaryStats.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-01.
//

import SwiftUI
import CoreData

struct SummaryStats: View {
    @State var showingWeekly = false
    let unitFormatter = UnitFormatter()

    @EnvironmentObject var routeManager: RouteManager
        
    @FetchRequest var weeklyTrips: FetchedResults<Trip>
    @FetchRequest var monthlyTrips: FetchedResults<Trip>

    @AppStorage("selectedUnits") var selectedUnits = "metric"
    
    // filter out fetch request by week or month date ranges
    init(filters: [Date]) {
        _weeklyTrips = FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "startTimestamp >= %@", filters[1] as CVarArg))
        _monthlyTrips = FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "startTimestamp >= %@", filters[0] as CVarArg))

    }
    
    // totals are derived from the fetch results so they stay current as trips are added, edited, or removed
    private var selectedTrips: FetchedResults<Trip> {
        showingWeekly ? weeklyTrips : monthlyTrips
    }
    
    private var selectedDistance: Double {
        selectedTrips.reduce(0) { $0 + $1.distance }
    }
    
    // only include as business km if it has a reimbursement amount > 0
    private var selectedBusinessKM: Double {
        selectedTrips.filter { $0.amountReimbursable > 0 }.reduce(0) { $0 + $1.distance }
    }
    
    private var selectedHours: Double {
        selectedTrips.reduce(0) { $0 + $1.secondsElapsed }
    }
    
    private var selectedReimbursable: Double {
        selectedTrips.reduce(0) { $0 + $1.amountReimbursable }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            HStack {
                // buttons to toggle between monthly and weekly data
                Button {
                    withAnimation {
                        showingWeekly = false
                    }
                } label: {
                    Text("This Month")
                        .font(.custom("Gilroy", size: 24))
                        .padding(.trailing)
                        .foregroundColor(.primary)
                        .opacity(showingWeekly == true ? 0.2 : 1)
                }
                
                Button {
                    withAnimation {
                        showingWeekly = true
                    }
                } label: {
                    Text("This Week")
                        .font(.custom("Gilroy", size: 24))
                        .foregroundColor(.primary)
                        .opacity(showingWeekly == true ? 1 : 0.2)
                }

            }
            // display metrics in a 2x2 arrangement
            HStack() {
                Metric(data: "\(unitFormatter.formatDistance(distance: selectedDistance, selectedUnits: selectedUnits))", descriptor: selectedUnits == "metric" ? "total km" : "total mi")
                    .frame(width: 150, alignment: .leading)
                Metric(data: "\(unitFormatter.formatDistance(distance: selectedBusinessKM, selectedUnits: selectedUnits))", descriptor: selectedUnits == "metric" ? "business km" : "business mi")
                    .frame(width: 150, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            HStack() {
                Metric(data: String(format:"%.1f", routeManager.secondstoHours(seconds: selectedHours)), descriptor: "hours driven")
                    .frame(width: 150, alignment: .leading)
                Metric(data: unitFormatter.formatReimbursable(amount: selectedReimbursable), descriptor: "reimbursable", color: Color.green)
                    .frame(width: 150, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(30)
    }
}
