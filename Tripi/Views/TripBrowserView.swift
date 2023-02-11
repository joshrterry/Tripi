//
//  TripBrowserView.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-09-07.
//

import SwiftUI
import MapKit

struct TripBrowserView: View {
    @State var hasScrolled = false
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Trip.startTimestamp, ascending: false)], animation: .default)
    private var trips: FetchedResults<Trip>
    
    func formatTimestamp(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        return dateFormatter.string(from: date)
    }
    
    @State private var span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    
    
    var body: some View {
        
        NavigationView {
            ZStack {
                Color("Background").ignoresSafeArea()
                ScrollView {
                    scrollDetection
                    ForEach(trips, id: \.self) { trip in
                        Preview(previewStyle: .expanded, trip: trip, distance: trip.distance, date: formatTimestamp(date: trip.startTimestamp ?? Date()), color: .green, time: trip.time ?? "", avgSpeed: trip.averageSpeed, starTime: trip.startTimestamp ?? Date(), endTime: trip.endTimestamp ?? Date(), tags: trip.tags!, region: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: trip.region[0], longitude: trip.region[1]), span: MKCoordinateSpan(latitudeDelta: trip.region[2], longitudeDelta: trip.region[3])), routeCoords: trip.routeWaypoints.map { CLLocationCoordinate2D(latitude: $0[0], longitude: $0[1]) }, notes: trip.notes ?? "")
                    }
                }
                .coordinateSpace(name: "scroll")
                .safeAreaInset(edge: .top, content: {
                    Color.clear.frame(height: 85)
                })
                .safeAreaInset(edge: .bottom, content: {
                    Color.clear.frame(height: 85)
                })
                .overlay(NavigationBar(title: "Browse", hasScrolled: $hasScrolled))
                .navigationBarHidden(true)
            }
        }
        
    }
    
    var scrollDetection: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: ScrollPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)
        }
        .frame(height: 0)
        .onPreferenceChange(ScrollPreferenceKey.self, perform: { value in
            withAnimation(.easeInOut) {
                if value < 0 {
                    hasScrolled = true
                } else {
                    hasScrolled = false
                }
            }
        })
    }
}

struct TripBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        TripBrowserView()
    }
}
