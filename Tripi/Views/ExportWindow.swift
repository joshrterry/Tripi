//
//  ExportWindow.swift
//  Tripi
//
//  Created by Joshua Terry on 2023-01-04.
//

import SwiftUI


struct Field: Identifiable {
    var id: String
    var includeMetric = false
    var data = ""
}

struct ExportWindow: View {
    @State var startDate = Date.now
    @State var endDate = Date.now
    @State var hasScrolled = false
    @State var noMetricsSelected = true
    @State var tripCount = 0
    @State var metricCount = 0
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Trip.startTimestamp, ascending: false)], animation: .default)
    var trips: FetchedResults<Trip>
    let fileManager = FileManager()
        
    @State var fields = [
        Field(id: "Start time", includeMetric: true),
        Field(id: "End time", includeMetric: true),
        Field(id: "Duration"),
        Field(id: "Distance", includeMetric: true),
        Field(id: "Amount reimbursable"),
        Field(id: "Notes")
    ]
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            List {
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
                .onChange(of: startDate) { newValue in
                    tripCount = 0
                    for trip in trips {
                        if trip.startTimestamp ?? Date() >= Calendar.current.startOfDay(for: startDate) && trip.endTimestamp ?? Date() <= Calendar.current.startOfDay(for: endDate + 86400) {
                            tripCount += 1
                        }
                    }
                }
                .onChange(of: endDate) { newValue in
                    tripCount = 0
                    for trip in trips {
                        if trip.startTimestamp ?? Date() >= Calendar.current.startOfDay(for: startDate) && trip.endTimestamp ?? Date() <= Calendar.current.startOfDay(for: endDate + 86400) {
                            tripCount += 1
                        }
                    }
                }
               
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
                
                ShareLink(item: fileManager.generateCSV(trips: trips, startDate: startDate, endDate: endDate, fields: fields.filter({
                    $0.includeMetric == true
                }))) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export \(tripCount) trips...")
                    }
                }.disabled(noMetricsSelected)
                
                
            }.scrollContentBackground(.hidden)
                .coordinateSpace(name: "scroll")
                .safeAreaInset(edge: .top, content: {
                    Color.clear.frame(height: 50)
            })

            .overlay(NavigationBar(showingButttons: false, title: "Export", hasScrolled: $hasScrolled))
            .offset(y: 40)
            .navigationBarHidden(true)
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

struct ExportWindow_Previews: PreviewProvider {
    static var previews: some View {
        ExportWindow()
    }
}
