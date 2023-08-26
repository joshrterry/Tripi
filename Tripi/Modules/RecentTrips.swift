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
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Trip.startTimestamp, ascending: false)], predicate: NSPredicate(format: "startTimestamp >= %@",  Date.now.addingTimeInterval(-604800) as CVarArg), animation: .default)
    private var trips: FetchedResults<Trip>
    
    func formatTimestamp(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        return dateFormatter.string(from: date)
    }
    
    @State private var span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    @State private var hasTrips = 0
    
    @AppStorage("selectedUnits") var selectedUnits = "metric"
    let unitFormatter = UnitFormatter()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recent Trips")
                .font(.custom("Gilroy", size: 24))
                .padding(.leading, 30)
            
            if hasTrips == 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 18) {
                        
                        ForEach(trips, id: \.self) { trip in
                            // only display trips that occurred within the past 7 days
                            //                            if trip.startTimestamp ?? Date() > Date.now.addingTimeInterval(-604800) {
                            // handle errors with index out of range
                            if trip.region.reduce(0, +) != 0 { // take the sum of all values in array. If 0, trip is stil in progress
                                // creates the trip previews and formats and passes all required parameters
                                Preview(trip: trip,
                                        distance: unitFormatter.formatDistance(distance: trip.distance, selectedUnits: selectedUnits),
                                        date: formatTimestamp(date: trip.startTimestamp ?? Date()),
                                        color: .green,
                                        time: trip.time ?? "00:00",
                                        avgSpeed: unitFormatter.formatSpeed(speed: trip.averageSpeed, selectedUnits: selectedUnits),
                                        starTime: trip.startTimestamp ?? Date(),
                                        endTime: trip.endTimestamp ?? Date(),
                                        tags: trip.tags!,
                                        amountReimbursable: trip.amountReimbursable,
                                        region: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: trip.region[0], longitude: trip.region[1]), span: MKCoordinateSpan(latitudeDelta: trip.region[2], longitudeDelta: trip.region[3])),
                                        routeCoords: trip.routeWaypoints.map { CLLocationCoordinate2D(latitude: $0[0], longitude: $0[1]) },
                                        notes: trip.notes ?? "")
                            }
                            //                            }
                        }
                        
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 22)
                }
                
            } else if hasTrips == 0 {
                VStack {
                    Spacer()
                        .frame(height: 120)
                    HStack(alignment: .center) {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(.circular)
                        Spacer()
                    }
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
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                if trips.count > 0 {
                    hasTrips = 1
                } else if trips.count == 0 {
                    hasTrips = 2
                }
            }
        }
    }
}
