//
//  SummaryStats.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-01.
//

import SwiftUI

struct SummaryStats: View {
    @State var selectedDistance = 0.0
    @State var selectedBusinessKM = 0.0
    @State var selectedHours = 0.0
    @State var showingWeekly = false

    @EnvironmentObject var routeManager: RouteManager
        
    @FetchRequest var weeklyTrips: FetchedResults<Trip>
    @FetchRequest var monthlyTrips: FetchedResults<Trip>

    
    init(filters: [Date]) {
        _weeklyTrips = FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "startTimestamp >= %@", filters[1] as CVarArg))
        _monthlyTrips = FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "startTimestamp >= %@", filters[0] as CVarArg))

    }
    
    func loadData() {
        selectedDistance = 0.0
        selectedBusinessKM = 0.0
        selectedHours = 0.0
        if showingWeekly {
            for trip in weeklyTrips {
                selectedDistance += trip.distance
                selectedHours += trip.secondsElapsed
                if trip.expenseTag == "business" {
                    selectedBusinessKM += trip.distance
                }
            }
        } else {
            for trip in monthlyTrips {
                selectedDistance += trip.distance
                selectedHours += trip.secondsElapsed
                if trip.expenseTag == "business" {
                    selectedBusinessKM += trip.distance
                }
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            HStack {
                Button {
                    showingWeekly = false
                    loadData()
                } label: {
                    Text("This Month")
                        .font(.custom("Gilroy", size: 24))
                        .padding(.trailing)
                        .foregroundColor(.primary)
                        .opacity(showingWeekly == true ? 0.2 : 1)
                }
                
                Button {
                    showingWeekly = true
                    loadData()
                } label: {
                    Text("This Week")
                        .font(.custom("Gilroy", size: 24))
                        .foregroundColor(.primary)
                        .opacity(showingWeekly == true ? 1 : 0.2)
                }

            }
            HStack() {
                Metric(data: String(format:"%.1f", selectedDistance), descriptor: "total km")
                    .frame(width: 150, alignment: .leading)
                Metric(data: String(format:"%.1f", selectedBusinessKM), descriptor: "business km")
                    .frame(width: 150, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            HStack() {
                Metric(data: String(format:"%.1f", routeManager.secondstoHours(seconds: selectedHours)), descriptor: "hours driven")
                    .frame(width: 150, alignment: .leading)
                Metric(data: "$94.32", descriptor: "reimbursable", color: Color.green)
                    .frame(width: 150, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(30)
        .onAppear {
            loadData()
        }
    }
}

struct SummaryStats_Previews: PreviewProvider {
    static var previews: some View {
        SummaryStats(filters: [Date(), Date()])
    }
}
