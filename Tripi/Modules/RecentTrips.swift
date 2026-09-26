//
//  RecentTrips.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-01.
//

import SwiftUI
import CoreData
import CoreLocation
import MapKit

struct RecentTrips: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Trip.startTimestamp, ascending: false)], predicate: NSPredicate(format: "startTimestamp >= %@",  Date.now.addingTimeInterval(-604800) as CVarArg), animation: .default)
    private var trips: FetchedResults<Trip>
    
    func formatTimestamp(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        return dateFormatter.string(from: date)
    }
    
    @State private var span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recent Trips")
                .font(.custom("Gilroy", size: 24))
                .padding(.leading, 30)
            
            if trips.contains(where: { $0.hasRoute }) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 18) {
                        
                        ForEach(trips, id: \.self) { trip in
                            // only display trips that occurred within the past 7 days
                            //                            if trip.startTimestamp ?? Date() > Date.now.addingTimeInterval(-604800) {
                            // handle errors with index out of range
                            if trip.hasRoute {
                                // creates the trip previews and formats and passes all required parameters
                                Preview(trip: trip,
                                        distance: trip.distance,
                                        date: formatTimestamp(date: trip.startTimestamp ?? Date()),
                                        color: .green,
                                        time: trip.time ?? "00:00",
                                        avgSpeed: trip.averageSpeed,
                                        starTime: trip.startTimestamp ?? Date(),
                                        endTime: trip.endTimestamp ?? Date(),
                                        tags: trip.tags ?? NSOrderedSet(),
                                        amountReimbursable: trip.amountReimbursable,
                                        region: trip.mapRegion,
                                        routeCoords: trip.routeCoordinates,
                                        notes: trip.notes ?? "")
                            }
                            //                            }
                        }
                        
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 22)
                }
                
            } else {
                VStack {
                    Spacer()
                        .frame(height: 120)
                    HStack(alignment: .center) {
                        Spacer()
                        Text("No trips to display")
                            .opacity(0.4)
                            .font(.custom("Gilroy", size: 18))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
