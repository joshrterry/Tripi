//
//  ExportWindow.swift
//  Tripi
//
//  Created by Joshua Terry on 2023-01-04.
//

import SwiftUI
import CoreData


struct Field: Identifiable {
    var id: String
    var includeMetric = false
    var data = ""
}

struct ExportWindow: View {
    @State var startDate = Calendar.current.startOfDay(for: Date.now)
    @State var endDate = Date.now
    @State var hasScrolled = false
    @State var noMetricsSelected = true
    @State var tripCount = 0
    @State var metricCount = 0
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Trip.startTimestamp, ascending: false)], animation: .default)
    var trips: FetchedResults<Trip>
    let fileManager = FileManager()
    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \UserTag.dateCreated, ascending: true)], animation: .default)
    private var tags: FetchedResults<UserTag>
    
    @State var selectedTags: [String] = []
    
    // dictionary of possible fields; first 3 are on by default
    @State var fields = [
        Field(id: "Start time", includeMetric: true),
        Field(id: "End time", includeMetric: true),
        Field(id: "Distance", includeMetric: true),
        Field(id: "Duration"),
        Field(id: "Average Speed"),
        Field(id: "Amount Reimbursable"),
        Field(id: "Notes")
    ]
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            List {
                // select start and end date range
                Section {
                    ZStack {
                        scrollDetection
                        DatePicker(selection: $startDate, in: ...Date.now, displayedComponents: .date) {
                            Text("Start Date")
                        }
                    }
                    DatePicker(selection: $endDate, in: startDate...Date.now, displayedComponents: .date) {
                        Text("End Date")
                    }
                }
                // if selected tags changes, determine new amount of available trips
                .onChange(of: selectedTags) { _, newValue in
                    tripCount = 0
                    for trip in trips {
                        if trip.startTimestamp ?? Date() >= Calendar.current.startOfDay(for: startDate) && trip.endTimestamp ?? Date() <= Calendar.current.startOfDay(for: endDate + 86400) {
                            var tagNames: [String] = []
                            for tag in trip.tags! {
                                tagNames.append((tag as AnyObject).name)
                            }
                            for tagName in tagNames {
                                if selectedTags.contains(tagName) {
                                    tripCount += 1
                                    break
                                }
                            }
                            if selectedTags.isEmpty {
                                tripCount += 1
                            }
                        }
                    }
                }
                // if selected start date changes, determine new amount of available trips
                .onChange(of: startDate) { _, newValue in
                    tripCount = 0
                    for trip in trips {
                        if trip.startTimestamp ?? Date() >= Calendar.current.startOfDay(for: startDate) && trip.endTimestamp ?? Date() <= Calendar.current.startOfDay(for: endDate + 86400) {
                            var tagNames: [String] = []
                            for tag in trip.tags! {
                                tagNames.append((tag as AnyObject).name)
                            }
                            for tagName in tagNames {
                                if selectedTags.contains(tagName) {
                                    tripCount += 1
                                    break
                                }
                            }
                            if selectedTags.isEmpty {
                                tripCount += 1
                            }
                        }
                    }

                }
                // if selected end date changes, determine new amount of available trips
                .onChange(of: endDate) { _, newValue in
                    tripCount = 0
                    for trip in trips {
                        if trip.startTimestamp ?? Date() >= Calendar.current.startOfDay(for: startDate) && trip.endTimestamp ?? Date() <= Calendar.current.startOfDay(for: endDate + 86400) {
                            var tagNames: [String] = []
                            for tag in trip.tags! {
                                tagNames.append((tag as AnyObject).name)
                            }
                            for tagName in tagNames {
                                if selectedTags.contains(tagName) {
                                    tripCount += 1
                                    break
                                }
                            }
                            if selectedTags.isEmpty {
                                tripCount += 1
                            }
                        }
                    }

                }
                // when view first appears, determine initial amount of available trips
                .onAppear {
                    tripCount = 0
                    for trip in trips {
                        if trip.startTimestamp ?? Date() >= Calendar.current.startOfDay(for: startDate) && trip.endTimestamp ?? Date() <= Calendar.current.startOfDay(for: endDate + 86400) {
                            var tagNames: [String] = []
                            for tag in trip.tags! {
                                tagNames.append((tag as AnyObject).name)
                            }
                            for tagName in tagNames {
                                if selectedTags.contains(tagName) {
                                    tripCount += 1
                                    break
                                }
                            }
                            if selectedTags.isEmpty {
                                tripCount += 1
                            }
                        }
                    }

                }
                
                // checkboxes to apply tag filters
                Section {
                    ForEach(tags) { tag in
                        Button {
                            if selectedTags.contains(tag.name ?? "") {
                                selectedTags.remove(at: selectedTags.firstIndex(of: tag.name ?? "") ?? 0)
                            } else {
                                selectedTags.append(tag.name ?? "Unknown tag")
                            }

                        } label: {
                            HStack {
                                Text(tag.name ?? "")
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedTags.contains(tag.name ?? "") {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } header: {
                    Text("Filter by tags")
                }
                
                // configure metrics that appear in export file
                Section {
                    ForEach($fields) { $field in
                        Toggle(field.id, isOn: $field.includeMetric)
                    }
                } header: {
                    Text("Configure metrics in export file")
                }
                .onReceive(fields.publisher) { newValue in
                    metricCount = 0
                    for field in fields {
                        if field.includeMetric == true {
                            metricCount += 1
                        }
                    }
                    withAnimation {
                        if metricCount > 0 && tripCount > 0 {
                            noMetricsSelected = false
                        } else {
                            noMetricsSelected = true
                        }
                    }
                }
                
                // share button at bottom of screen
                ShareLink(item: fileManager.generateCSV(trips: trips, startDate: startDate, endDate: endDate, tags: selectedTags, fields: fields.filter({
                    $0.includeMetric == true
                }))) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export \(tripCount) trips...")
                    }
                }.disabled(noMetricsSelected) // disable if no metrics are selected or no trips in range
                
                
            }.scrollContentBackground(.hidden)
                .coordinateSpace(name: "scroll")
                .safeAreaInset(edge: .top, content: {
                    Color.clear.frame(height: 50)
                })
                .safeAreaInset(edge: .bottom, content: {
                    Color.clear.frame(height: 50)
                })
            
                .overlay(NavigationBar(showingButttons: false, title: "Export", hasScrolled: $hasScrolled))
                .offset(y: 40)
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            Button("Done", action: dismiss.callAsFunction).padding(25)
                        }
                        Spacer()
                    }
                )
                .navigationBarHidden(true)
        }.onAppear {
            for trip in trips {
                // handle errors with index out of range
                if trip.region.reduce(0, +) == 0 { // take the sum of all values in array. If 0, trip is stil in progress
                    PersistenceController.shared.delete(trip: trip)
                }
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
