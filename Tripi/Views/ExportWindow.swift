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
    let fileManager = FileManager()
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
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
                ShareLink(item: fileManager.generateCSV(trips: trips, startDate: startDate, endDate: endDate))
                
                
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
