//
//  TripDetailView.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-08-31.
//

import SwiftUI
import CoreData
import MapKit
import WrappingHStack

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
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // polyline map at top of view
                PolylineMap(region: $region, routeCoordinates: $routeCoords, isTracking: false, edgeInsets: UIEdgeInsets(top: 40, left: 20, bottom: geometry.size.height/3.8, right: 20))
//                StaticPolylineMap(region: $region, routeCoordinates: $routeCoords)
                    .scaleEffect(scrollAmount > 0 ? 1 + scrollAmount/1000 : 1) // scale animation when scrolling above safe area
                    .edgesIgnoringSafeArea(.all)
                    .frame(height: geometry.size.height/2)
                ScrollView(showsIndicators: false) {
                    if monitoringScroll {
                        scrollDetection
                    }
                    VStack {
                        Spacer()
                            .frame(height: geometry.size.height/3)
                        ZStack(alignment: .topLeading) {
                            Rectangle()
                                .foregroundColor(Color("Background"))
                                .cornerRadius(50, corners: [.topLeft, .topRight])
                                .shadow(color: .primary.opacity(0.15), radius: 20, x: -5, y: -5)
                                .frame(height: 1200)
                                .edgesIgnoringSafeArea(.all)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                // header includes date, time, and pin/delete menus
                                Header(trip: trip, startTime: startTime, endTime: endTime)
                                // metrics include distance, duration, and time
                                Metrics(selectedUnits: selectedUnits, distance: distance, avgSpeed: avgSpeed, time: time)
                                // includes tags section and related reimbursement amount
                                Reimbursement(amountReimbursable: amountReimbursable, trip: trip, globalTags: globalTags, tags: tags, distance: distance)
                                           
                                // graph of average speed at different points during the trip
                                Text("Speed")
                                    .font(.custom("Gilroy", size: 24))
                                    .padding(.top, 15)
                                    .padding(.leading, 30)
                                Graphs(trip: trip)
                                    .frame(height: 175)
                                    .padding(.horizontal, 30)
                                
                                // notes seciton for user inputted text
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
    }
    
    // save changes to database
    func uploadChanges() {
        guard !trip.isDeleted, trip.managedObjectContext != nil else { return }
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
            
            if value > 165 {
                dismiss()
            }

            scrollAmount = value
        })
    }

}

extension TripDetailView {
    // convenience initializer that reads every field from the trip itself
    init(trip: Trip) {
        self.init(trip: trip,
                  distance: trip.distance,
                  time: trip.time ?? "00:00",
                  avgSpeed: trip.averageSpeed,
                  startTime: trip.startTimestamp ?? Date(),
                  endTime: trip.endTimestamp ?? Date(),
                  notes: trip.notes ?? "",
                  region: trip.mapRegion,
                  routeCoords: trip.routeCoordinates,
                  tags: trip.tags ?? NSOrderedSet(),
                  amountReimbursable: trip.amountReimbursable)
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
    @State private var showingDeleteConfirmation = false
    @State private var pinFeedback = 0 // bumped only by the pin button so loading a pinned trip doesn't buzz
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            Text("Trip Summary")
                .font(.custom("Gilroy", size: 32))
            Spacer()
            
            // menu for pinning or deleting
            Menu {
                Button {
                    isPinned.toggle()
                    pinFeedback += 1
                    trip.isPinned = isPinned
                    PersistenceController.shared.save()
                } label: {
                    Label(isPinned ? "Unpin Trip" : "Pin Trip", systemImage: "pin")
                }
//                Button {
//                    let duplicateTrip = trip
//                    
//                } label: {
//                    Label("Duplicate Trip", systemImage: "doc.on.doc")
//                }
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Remove Trip", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.system(size: 32))
            }
            .confirmationDialog("Remove this trip?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                Button("Remove Trip", role: .destructive) {
                    dismiss()
                    // delete after the pop animation so the list animates the trip out rather than the detail view going blank
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation {
                            PersistenceController.shared.delete(trip: trip)
                        }
                    }
                }
            } message: {
                Text("This can't be undone.")
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 40)
        .sensoryFeedback(.success, trigger: pinFeedback)
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
    let unitFormatter = UnitFormatter()
    @State var selectedUnits: String
    @State var distance: Double
    @State var avgSpeed: Double
    @State var time: String
    
    var body: some View {
        // display recorded metrics
        HStack(spacing: 32) {
            Metric(data: String(format:"%.1f", unitFormatter.formatDistance(distance: distance, selectedUnits: selectedUnits)), descriptor: (selectedUnits == "metric" ? "TOTAL KM" : "TOTAL MI"))
            Metric(data: time, descriptor: "MINUTES")
            Metric(data: String(format:"%.0f", unitFormatter.formatSpeed(speed: avgSpeed, selectedUnits: selectedUnits)), descriptor: (selectedUnits == "metric" ? "AVG KPH" : "AVG MPH"))
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
        guard !trip.isDeleted, trip.managedObjectContext != nil else { return }
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
            
            // limited text field for user input
            TextField("Start typing...", text: $notes, axis: .vertical)
                .lineLimit(4)
                .focused($isTyping)
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                .padding(.horizontal, 45)
                .padding(.top, 20)
                .frame(height: 150, alignment: .topLeading)
                // only allow a max of 120 characters
                .onChange(of: notes) { _, newValue in
                    notes = String(newValue.prefix(120))
                }
            // character count, shown while typing so the 120 limit isn't a surprise
            if showingDone {
                Text("\(notes.count)/120")
                    .font(.custom("Gilroy", size: 13))
                    .foregroundColor(notes.count >= 120 ? .red : .secondary)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: notes.count)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 45)
                    .padding(.bottom, 22)
                    .transition(.opacity)
            }
            if showingDone {
                // done button for textfield
                Button {
                    isTyping = false
                    uploadChanges()
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
                .zIndex(1)
            }
        }
        .onTapGesture {
            isTyping = true
        }
        .onChange(of: isTyping) { _, value in
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
    @State var isEditing = false
    @State private var tagID = NSOrderedSet()
    
    func uploadChanges() {
        guard !trip.isDeleted, trip.managedObjectContext != nil else { return }
        trip.tags = tags
        PersistenceController.shared.save()
    }
    
    var body: some View {
        // amount reimbursable metric
        Metric(data: unitFormatter.formatReimbursable(amount: amountReimbursable), descriptor: "reimbursable", color: Color.green)
            .padding(.leading, 30)
            .padding(.bottom, 15)
        
        HStack(spacing: 15) {
            
            Text("Tags")
                .font(.custom("Gilroy", size: 24))
                .padding(.leading, 30)
            Spacer()
            Menu {
                // display all available tags
                ForEach(globalTags, id: \.self) { tag in
                    // toggle tag on or off for this trip
                    Button {
                        withAnimation {
                            let mutableTags = tags.mutableCopy() as! NSMutableOrderedSet
                            if tags.contains(tag) {
                                mutableTags.remove(tag)
                            } else {
                                mutableTags.add(tag)
                            }
                            tags = mutableTags.copy() as! NSOrderedSet
                            uploadChanges()
                        }

                    } label: {
                        if tags.contains(tag) {
                            Label(tag.wrappedName, systemImage: "checkmark")
                        } else {
                            Text(tag.wrappedName)
                        }
                    }
                    
                }
            } label: {
                ZStack(alignment: .center) {
                    Rectangle()
                        .frame(width: 30, height: 30)
                        .cornerRadius(15)
                        .foregroundColor(Color(.systemGray5))
                    
                        Image(systemName: "plus")
                    .foregroundColor(Color.primary)
                }
            }
            
            // edit button
            Button {
                withAnimation {
                    isEditing.toggle()
                }
            } label: {
                ZStack(alignment: .center) {
                    Rectangle()
                        .frame(width: 30, height: 30)
                        .cornerRadius(15)
                        .foregroundColor(Color(.systemGray5))
                    
                    Image(systemName: isEditing ? "pencil.slash" : "pencil")
                    .foregroundColor(Color.primary)
                }
            }

        }
        .padding(.trailing, 30)

        
        

        
        HStack(alignment: .top) {

            // display placeholder text
            if tags.count == 0 {
                Text("No tags to display")
                    .opacity(0.4)
                    .font(.custom("Gilroy", size: 18))
                    .foregroundColor(.primary)
            } else {
                
                // display each tag applied to the trip visually
                WrappingHStack(trip.tags?.array as? [UserTag] ?? [], id: \.self, spacing: .constant(8), lineSpacing: 8) { tag in
                Button {
                    if isEditing {
                        withAnimation {
                            let mutableTags = tags.mutableCopy() as! NSMutableOrderedSet
                            mutableTags.remove(tag)
                            tags = mutableTags.copy() as! NSOrderedSet
                            uploadChanges()
                        }
                    }
                    } label: {
                        Tag(name: tag.wrappedName, colour: tag.displayColour)
                            .id(tagID)
                            .foregroundColor(.primary)
                            .zIndex(1)
                            .overlay(alignment: .topTrailing) {
                                ZStack {
                                    if isEditing {
                                        Circle()
                                            .foregroundColor(.white)
                                            .frame(width: 24, height: 24)
                                        Image(systemName: "x.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.red)
                                            .zIndex(1)
                                    }
                                }.offset(x: 9, y: -9)

                            }
                    }
                    .onChange(of: tags) { _, newValue in
                        tagID = newValue
                    }
                }
                .padding(.trailing, 5)

            }


            
        }
        .padding(.leading, 30)
        .padding(.vertical, 15)
        .sensoryFeedback(.selection, trigger: tags)
        // if tags change, update reimbursement amount and save changes
        .onChange(of: tags) { _, _ in
            if tags.count >= 1 {
                trip.amountReimbursable = (trip.tagsArray.first?.reimbursementAmount ?? 0) * distance
                PersistenceController.shared.save()
                print(trip.amountReimbursable)
            } else {
                trip.amountReimbursable = 0.0
                isEditing = false
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
