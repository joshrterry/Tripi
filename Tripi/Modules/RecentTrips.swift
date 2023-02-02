//
//  RecentTrips.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-01.
//

import SwiftUI
import CoreLocation
import MapKit

struct RecentTrips: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Trip.startTimestamp, ascending: false)], animation: .default)
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
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    
                    // Handle errors with index out of range
                    ForEach(trips, id: \.self) { trip in
                        if trip.region.reduce(0, +) != 0 {
                            Preview(trip: trip, distance: trip.distance, date: formatTimestamp(date: trip.startTimestamp ?? Date()), color: .green, time: trip.time ?? "00:00", avgSpeed: trip.averageSpeed, starTime: trip.startTimestamp ?? Date(), endTime: trip.endTimestamp ?? Date(), tags: trip.tags!, region: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: trip.region[0], longitude: trip.region[1]), span: MKCoordinateSpan(latitudeDelta: trip.region[2], longitudeDelta: trip.region[3])), routeCoords: trip.routeWaypoints.map { CLLocationCoordinate2D(latitude: $0[0], longitude: $0[1]) }, notes: trip.notes ?? "")
                        }
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
