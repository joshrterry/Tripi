//
//  TripDetailView.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-08-31.
//

import SwiftUI
import MapKit

struct TripDetailView: View {
    @State var trip: Trip
    @State var distance: Double
    @State var time: String
    @State var avgSpeed: Double
    @State var startTime: Date
    @State var endTime: Date
    @State var notes: String
    @State var region: MKCoordinateRegion
    @State var routeCoords: [CLLocationCoordinate2D]
    @State var tags: NSOrderedSet
    @State var descriptor = ""
    @State var showingDone = false
    @State var amountReimbursable: Double
    @Environment(\.dismiss) private var dismiss
    @AppStorage("showingTabBar") var showingTabBar: Bool = true
    @AppStorage("selectedUnits") var selectedUnits = "metric"
    @State var scrollAmount = 0.0
    @State var coveringStatusBar = false
    @State var monitoringScroll = false
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \UserTag.dateCreated, ascending: true)], animation: .default)
    private var globalTags: FetchedResults<UserTag>
    
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            PolylineMap(region: $region, routeCoordinates: $routeCoords, isTracking: false, edgeInsets: UIEdgeInsets(top: 0, left: 20, bottom: 150, right: 20))
                .scaleEffect(scrollAmount > 0 ? 1 + scrollAmount/1000 : 1)
                .edgesIgnoringSafeArea(.all)
                .frame(height: 300)
            ScrollView(showsIndicators: false) {
                if monitoringScroll {
                    scrollDetection
                }
                VStack {
                    Spacer()
                        .frame(height: 250)
                    ZStack(alignment: .topLeading) {
                        Rectangle()
                            .foregroundColor(Color("Background"))
                            .cornerRadius(50, corners: [.topLeft, .topRight])
                            .shadow(color: .primary.opacity(0.15), radius: 20, x: -5, y: -5)
                            .frame(height: 1200)
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Header(trip: trip, startTime: startTime, endTime: endTime)
                            
                            Metrics(selectedUnits: selectedUnits, distance: distance, avgSpeed: avgSpeed, time: time)
                            
                            Reimbursement(amountReimbursable: amountReimbursable, trip: trip, globalTags: globalTags, tags: tags, distance: distance)
                                                        
                            Text("Speed")
                                .font(.custom("Gilroy", size: 24))
                                .padding(.top, 15)
                                .padding(.leading, 30)
                            Graphs(trip: trip)
                                .frame(height: 175)
                                .padding(.horizontal, 30)
                            
                            Notes(notes: notes, showingDone: showingDone, trip: trip)
                                
                        }
                        
                    }
                }
            }.toolbarBackground(.hidden, for: .navigationBar)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: BackButton(dismiss: self.dismiss).opacity(1+scrollAmount/150))
                .edgesIgnoringSafeArea(.all)
        }.onDisappear {
            showingTabBar = true
        }
        .onAppear {
            showingTabBar = false
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                monitoringScroll = true
            }
        }
        .overlay(alignment: .top) {
            if coveringStatusBar {
                ZStack(alignment: .top) {
                    Rectangle()
                        .foregroundStyle(.thinMaterial)
                        .frame(height: 100)
                    Text("Trip Summary")
                        .font(.custom("Gilroy", size: 18))
                        .padding(.top, 60)
                }
                .edgesIgnoringSafeArea(.all)

            }
            }


    }
    
    func uploadChanges() {
        trip.tags = tags
        trip.notes = notes
        PersistenceController.shared.save()
    }
    
    var scrollDetection: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: ScrollPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)
        }
        .frame(height: 0)
        .onPreferenceChange(ScrollPreferenceKey.self, perform: { value in
            if value < -200 {
                withAnimation(.easeInOut(duration: 0.3)) {
                    coveringStatusBar = true
                }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    coveringStatusBar = false
                }
            }

            scrollAmount = value
        })
    }

}

struct Header: View {
    @State var trip: Trip
    @State var startTime: Date
    @State var endTime: Date
    
    func formatTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }
    
    func formatDay(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
    
    @State var isPinned = false
    
    var body: some View {
        HStack {
            Text("Trip Summary")
                .font(.custom("Gilroy", size: 32))
            Spacer()
            
            
            Menu {
                Button {
                    isPinned.toggle()
                    trip.isPinned = isPinned
                    PersistenceController.shared.save()
                } label: {
                    Label(isPinned ? "Unpin Trip" : "Pin Trip", systemImage: "pin")
                }
                Button {
                    PersistenceController.shared.delete(trip: trip)
                } label: {
                    Label("Delete Trip", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.system(size: 32))
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 40)
        .onAppear {
            isPinned = trip.isPinned
        }
        
        Text(formatTime(date: startTime)+" - "+formatTime(date: endTime)+" | "+formatDay(date: startTime))
            .font(.custom("Gilroy", size: 15))
            .foregroundColor(.gray)
            .padding(.leading, 30)
    }
}

struct Metrics: View {
    @State var selectedUnits: String
    @State var distance: Double
    @State var avgSpeed: Double
    @State var time: String
    
    var body: some View {
        HStack(spacing: 32) {
            Metric(data: String(format:"%.1f", distance), descriptor: (selectedUnits == "metric" ? "TOTAL KM" : "TOTAL MI"))
            Metric(data: time, descriptor: "MINUTES")
            Metric(data: String(format:"%.0f", avgSpeed), descriptor: (selectedUnits == "metric" ? "AVG KPH" : "AVG MPH"))
        }
        .padding(30)
    }
}

struct Notes: View {
    @State var notes: String
    @FocusState private var isTyping: Bool
    @State var showingDone: Bool
    @State var trip: Trip

    func uploadChanges() {
        trip.notes = notes
        PersistenceController.shared.save()
    }
    
    var body: some View {
        Text("Notes")
            .font(.custom("Gilroy", size: 24))
            .padding(.vertical, 15)
            .padding(.leading, 30)
        
        ZStack(alignment: .bottomTrailing) {
            Rectangle()
                .cornerRadius(20)
                .foregroundColor(Color(.systemGray5))
                .padding(.horizontal, 30)
                .frame(height: 150)
            TextEditor(text: $notes)
                .focused($isTyping)
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                .padding(.horizontal, 40)
                .padding(.top, 15)
                .frame(height: 150)
            if showingDone {
                Button {
                    isTyping = false
                } label: {
                    HStack {
                        Text("Done")
                            .font(.custom("Gilroy", size: 14))
                        Image(systemName: "checkmark.circle")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 7)
                    .background(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 50)
                    .padding(.bottom, 15)
                }
            }
        }
        .onChange(of: isTyping) { value in
            withAnimation {
                showingDone = value
            }
        }
        .onDisappear {
            uploadChanges()
        }
    }
}

struct Reimbursement: View {
    @State var amountReimbursable: Double
    let unitFormatter = UnitFormatter()
    @State var trip: Trip
    @State var globalTags: FetchedResults<UserTag>
    @State var tags: NSOrderedSet
    @State var distance: Double
    
    func uploadChanges() {
        trip.tags = tags
        PersistenceController.shared.save()
    }
    
    var body: some View {
        Metric(data: unitFormatter.formatReimbursable(amount: amountReimbursable), descriptor: "reimbursable", color: Color.green)
            .padding(.leading, 30)
            .padding(.bottom, 15)
        
        Text("Tags")
            .font(.custom("Gilroy", size: 24))
            .padding(.leading, 30)
        
        HStack(alignment: .top) {
            Menu {
                ForEach(globalTags, id: \.self) { tag in
                    Button {
                        let mutableTags = tags.mutableCopy() as! NSMutableOrderedSet
                        mutableTags.add(tag)
                        tags = mutableTags.copy() as! NSOrderedSet
                        uploadChanges()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text(tag.name!)
                        }
                    }
                    
                }
            } label: {
                ZStack(alignment: .center) {
                    Rectangle()
                        .frame(width: 80, height: 30)
                        .cornerRadius(15)
                        .foregroundColor(Color(.systemGray5))
                    
                    HStack {
                        Image(systemName: "plus")
                        Text("Add")
                    }
                    .foregroundColor(Color.primary)
                    .font(.custom("Gilroy", size: 16))
                }
                .padding(.leading, 30)
            }
            ForEach(trip.tags?.array as? [UserTag] ?? [], id: \.self) { tag in
                Tag(name: tag.name!, colour: Color(red: tag.colour![0] / 255, green: tag.colour![1] / 255, blue: tag.colour![2] / 255))
                    .contextMenu {
                        Button {
                            let mutableTags = tags.mutableCopy() as! NSMutableOrderedSet
                            mutableTags.remove(tag)
                            tags = mutableTags.copy() as! NSOrderedSet
                            uploadChanges()
                        } label: {
                            Label("Remove Tag", systemImage: "trash")
                        }
                    }
            }
            
        }
        .padding(.vertical, 15)
        
        .onChange(of: tags) { _ in
            if tags.count >= 1 {
                let tripsArray = trip.tags?.array as? [UserTag]
                trip.amountReimbursable = (tripsArray?[0].reimbursementAmount ?? 0) * distance
                PersistenceController.shared.save()
                print(trip.amountReimbursable)
            } else {
                trip.amountReimbursable = 0.0
            }
            withAnimation {
                amountReimbursable = trip.amountReimbursable
            }
        }
        .onDisappear {
            uploadChanges()
        }


    }
}

struct TripDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TripDetailView(trip: Trip(), distance: 200, time: "22:12", avgSpeed: 102, startTime: Date(), endTime: Date(), notes: "", region: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), routeCoords: [], tags: [], amountReimbursable: 0.0)
    }
}
