//
//  TripBrowserView.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-09-07.
//

import SwiftUI
import CoreData
import MapKit

struct TripBrowserView: View {
    @AppStorage("showingTabBar") var showingTabBar: Bool = true
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
    @State private var tripPendingDeletion: Trip?
    
    // completed trips matching the All/Pinned filter, grouped by the month they started in (newest first)
    private var tripsByMonth: [(month: Date, trips: [Trip])] {
        let visible = trips.filter { $0.hasRoute && (!showingPinned || $0.isPinned) }
        let grouped = Dictionary(grouping: visible) { trip in
            Calendar.current.dateInterval(of: .month, for: trip.startTimestamp ?? Date())?.start ?? Date()
        }
        return grouped.keys.sorted(by: >).map { (month: $0, trips: grouped[$0] ?? []) }
    }
    
    func formatMonth(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
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
                                        
                    // trips grouped under month headings
                    ForEach(tripsByMonth, id: \.month) { group in
                        Text(formatMonth(date: group.month))
                            .font(.custom("Gilroy", size: 18))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 30)
                            .padding(.top, 15)
                        ForEach(group.trips, id: \.self) { trip in
                            Preview(previewStyle: .expanded,
                                    trip: trip,
                                    distance: trip.distance,
                                    date: formatTimestamp(date: trip.startTimestamp ?? Date()),
                                    color: .green, time: trip.time ?? "",
                                    avgSpeed: trip.averageSpeed,
                                    starTime: trip.startTimestamp ?? Date(),
                                    endTime: trip.endTimestamp ?? Date(),
                                    tags: trip.tags ?? NSOrderedSet(),
                                    amountReimbursable: trip.amountReimbursable,
                                    region: trip.mapRegion,
                                    routeCoords: trip.routeCoordinates,
                                    notes: trip.notes ?? "")
                            // long-press shortcuts for pinning and removing without opening the trip
                            .contextMenu {
                                Button {
                                    withAnimation {
                                        trip.isPinned.toggle()
                                        PersistenceController.shared.save()
                                    }
                                } label: {
                                    Label(trip.isPinned ? "Unpin Trip" : "Pin Trip", systemImage: trip.isPinned ? "pin.slash" : "pin")
                                }
                                Button(role: .destructive) {
                                    tripPendingDeletion = trip
                                } label: {
                                    Label("Remove Trip", systemImage: "trash")
                                }
                            }
                        }
                    }
                    if tripsByMonth.isEmpty {
                        VStack {
                            Spacer()
                                .frame(height: 120)
                            HStack(alignment: .center) {
                                Spacer()
                                Text(showingPinned && trips.contains(where: { $0.hasRoute }) ? "No pinned trips" : "No trips to display")
                                    .opacity(0.4)
                                    .font(.custom("Gilroy", size: 18))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                        .transition(.opacity)
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
        }.onAppear {
            showingTabBar = true
        }
        .confirmationDialog("Remove this trip?", isPresented: Binding(get: { tripPendingDeletion != nil }, set: { if !$0 { tripPendingDeletion = nil } }), titleVisibility: .visible, presenting: tripPendingDeletion) { trip in
            Button("Remove Trip", role: .destructive) {
                withAnimation {
                    PersistenceController.shared.delete(trip: trip)
                }
            }
        } message: { _ in
            Text("This can't be undone.")
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
