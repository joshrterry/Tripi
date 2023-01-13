//
//  ExportWindow.swift
//  Tripi
//
//  Created by Joshua Terry on 2023-01-04.
//

import SwiftUI

struct ExportWindow: View {
    @State var startDate = Date.now
    @State var endDate = Date.now
    @State var hasScrolled = false
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Trip.startTimestamp, ascending: false)], animation: .default)
    var trips: FetchedResults<Trip>

    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            Text("Export")
            List {
                ZStack {
                    scrollDetection
                    DatePicker(selection: $startDate, in: ...Date.now, displayedComponents: .date) {
                        Text("Start Date")
                    }
                }
                DatePicker(selection: $endDate, in: startDate...Date.now, displayedComponents: .date) {
                    Text("End Date")
                }
                ShareLink(item: generateCSV())
//                Button {
//                 generateCSV()
//                } label: {
//                    Text("Export")
//                }
            }
                .coordinateSpace(name: "scroll")
                .safeAreaInset(edge: .top, content: {
                    Color.clear.frame(height: 50)
            })

            .overlay(NavigationBar(showingButttons: false, title: "Export", hasScrolled: $hasScrolled))
            .offset(y: 40)
            .navigationBarHidden(true)
        }
    }
    
    // https://youtu.be/7luhStOgXjk
    
    func generateCSV() -> URL {
        let sFileName = "export.csv"
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let documentURL = URL(filePath: documentDirectoryPath).appendingPathComponent(sFileName)
        let output = OutputStream.toMemory()
        let csvWriter = CHCSVWriter(outputStream: output, encoding: String.Encoding.utf8.rawValue, delimiter: ",".utf16.first!)
        
        // CSV File Header
        csvWriter?.writeField("TRIP_START_TIME")
        csvWriter?.writeField("TRIP_END_TIME")
        csvWriter?.writeField("TRIP_DISTANCE")
        csvWriter?.finishLine()
        
        // Data Array
        var tripsData = [[String]]()
        
        for trip in trips {
            if trip.startTimestamp ?? Date() >= Calendar.current.startOfDay(for: startDate) && trip.endTimestamp ?? Date() <= Calendar.current.startOfDay(for: endDate + 86400) {
                tripsData.append(["\(trip.startTimestamp ?? Date())", "\(trip.endTimestamp ?? Date())", "\(trip.distance)"])
            }


        }
        
        for elements in tripsData.enumerated() {
            csvWriter?.writeField(elements.element[0])
            csvWriter?.writeField(elements.element[1])
            csvWriter?.writeField(elements.element[2])
            csvWriter?.finishLine()
        }
        
        csvWriter?.closeStream()
        
        let buffer = (output.property(forKey: .dataWrittenToMemoryStreamKey) as? Data)!
        
        do {
            try buffer.write(to: documentURL)
        }
        catch {
            
        }
        return documentURL
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
