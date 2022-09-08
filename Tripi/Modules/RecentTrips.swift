//
//  RecentTrips.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-01.
//

import SwiftUI

struct RecentTrips: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Trip.startTimestamp, ascending: false)], animation: .default)
    private var trips: FetchedResults<Trip>
    
    func formatTimestamp(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recent Trips")
                .font(.custom("Gilroy", size: 24))
                .padding(.leading, 30)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(trips, id: \.self) { trip in
                        Preview(distance: trip.distance, date: formatTimestamp(date: trip.startTimestamp ?? Date()), category: "Business · $12.76", color: .green, time: trip.time ?? "", avgSpeed: trip.averageSpeed, starTime: trip.startTimestamp ?? Date(), endTime: trip.endTimestamp ?? Date())
                    }

                }
                .padding(.horizontal, 30)
                .padding(.vertical, 22)

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
    }
}

struct RecentTrips_Previews: PreviewProvider {
    static var previews: some View {
        RecentTrips()
    }
}
