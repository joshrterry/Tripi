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
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.33166, longitude: -122.03014),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    @State var routeCoords: [CLLocationCoordinate2D] = []
        

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recent Trips")
                .font(.custom("Gilroy", size: 24))
                .padding(.leading, 30)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(trips, id: \.self) { trip in
                        Preview(distance: trip.distance, date: formatTimestamp(date: trip.startTimestamp ?? Date()), category: "Business · $12.76", color: .green, time: trip.time ?? "", avgSpeed: trip.averageSpeed, starTime: trip.startTimestamp ?? Date(), endTime: trip.endTimestamp ?? Date(), region: region, routeCoords: routeCoords)
                            .onAppear {
                                for location in trip.locationsArray {
                                    routeCoords.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                                }
                            }
                        
                        
//                        ForEach(trip.locationsArray, id: \.self) { location in
//                            Text("\(location.wrappedLatitude)")
//                                .onAppear {
//                                    print("here: \(location.wrappedLatitude)")
//                                }
//                        }
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
