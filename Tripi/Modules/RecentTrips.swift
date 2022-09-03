//
//  RecentTrips.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-01.
//

import SwiftUI

struct RecentTrips: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Trip.timestamp, ascending: true)], animation: .default)
    private var trips: FetchedResults<Trip>
    
    func formatTimestamp(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
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
                        Preview(distance: String(format:"%.1f", trip.distance), date: formatTimestamp(date: trip.timestamp ?? Date()), category: "Business · $12.76", color: .green)
                    }
//                    Preview(distance: "36.7", date: "Today", category: "Business · $12.76", color: .green)
//                    Preview(distance: "12.1", date: "Yesterday", category: "Personal", color: .blue)
//                    Preview(distance: "50.3", date: "June 20", category: "Business · $43.76", color: .green)
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
