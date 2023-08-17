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
    @State var showingDateFilter = false
    @State var startDate = Date.now
    @State var endDate = Date.now
    
    @State private var span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    
    @State var showingPinned = false
    
    var body: some View {
        
        NavigationView {
            ZStack {
                Color("Background").ignoresSafeArea()
               
                ScrollView() {
                    scrollDetection
                    
                    // toggle between showing all trips and only pinned trips
                    HStack {
                        Button {
                            withAnimation {
                                showingPinned = false
                            }
                        } label: {
                            Text("All")
                                .font(.custom("Gilroy", size: 24))
                                .padding(.trailing)
                                .foregroundColor(.primary)
                                .opacity(showingPinned == true ? 0.2 : 1)
                        }
                        
                        // changes to only show pinned trips
                        Button {
                            withAnimation {
                                showingPinned = true
                            }
                        } label: {
                            Text("Pinned")
                                .font(.custom("Gilroy", size: 24))
                                .foregroundColor(.primary)
                                .opacity(showingPinned == true ? 1 : 0.2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.leading, 30)
                
                    // only show pinned trips if showingPinned is true
                    if showingPinned {
                        ForEach(trips, id: \.self) { trip in
                            if trip.isPinned {
                                // handle errors with index out of range
                                if trip.region.reduce(0, +) != 0 { // take the sum of all values in array. If 0, trip is stil in progress
                                    Preview(previewStyle: .expanded,
                                            trip: trip,
                                            distance: trip.distance,
                                            date: formatTimestamp(date: trip.startTimestamp ?? Date()),
                                            color: .green, time: trip.time ?? "",
                                            avgSpeed: trip.averageSpeed,
                                            starTime: trip.startTimestamp ?? Date(),
                                            endTime: trip.endTimestamp ?? Date(),
                                            tags: trip.tags!,
                                            amountReimbursable: trip.amountReimbursable,
                                            region: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: trip.region[0], longitude: trip.region[1]), span: MKCoordinateSpan(latitudeDelta: trip.region[2], longitudeDelta: trip.region[3])),
                                            routeCoords: trip.routeWaypoints.map { CLLocationCoordinate2D(latitude: $0[0], longitude: $0[1]) },
                                            notes: trip.notes ?? "")
                                }
                            }
                        }
                    } else {
                        // show all trips if showingPinned is false
                        ForEach(trips, id: \.self) { trip in
                            // handle errors with index out of range
                            if trip.region.reduce(0, +) != 0 { // take the sum of all values in array. If 0, trip is stil in progress
                                Preview(previewStyle: .expanded,
                                        trip: trip,
                                        distance: trip.distance,
                                        date: formatTimestamp(date: trip.startTimestamp ?? Date()),
                                        color: .green, time: trip.time ?? "",
                                        avgSpeed: trip.averageSpeed,
                                        starTime: trip.startTimestamp ?? Date(),
                                        endTime: trip.endTimestamp ?? Date(),
                                        tags: trip.tags!,
                                        amountReimbursable: trip.amountReimbursable,
                                        region: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: trip.region[0], longitude: trip.region[1]), span: MKCoordinateSpan(latitudeDelta: trip.region[2], longitudeDelta: trip.region[3])),
                                        routeCoords: trip.routeWaypoints.map { CLLocationCoordinate2D(latitude: $0[0], longitude: $0[1]) },
                                        notes: trip.notes ?? "")
                            }
                        }
                    }
                }
                .coordinateSpace(name: "scroll")
                .safeAreaInset(edge: .top, content: {
                    Color.clear.frame(height: 75)
                })
                .safeAreaInset(edge: .bottom, content: {
                    Color.clear.frame(height: 100)
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
