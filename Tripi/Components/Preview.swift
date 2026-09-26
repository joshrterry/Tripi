//
//  Preview.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-01.
//

import SwiftUI
import CoreData
import MapKit
import WrappingHStack

struct Preview: View {
    @State var previewStyle: LayoutStyle = .compact
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var routeManager: RouteManager
    @AppStorage("selectedUnits") var selectedUnits = "metric"
    
    @ObservedObject var trip: Trip // observed so the card (and the detail view it opens) reflect edits like tag changes
    var distance = 0.0 // always in km; converted for display
    var date = ""
    var color = Color.primary
    
    var time = ""
    var avgSpeed = 0.0
    var starTime: Date
    var endTime: Date
    
    var tags: NSOrderedSet
    
    var amountReimbursable = 0.0
    
    let unitFormatter = UnitFormatter()
    
    @State private var tagID = NSOrderedSet()
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Trip.endTimestamp, ascending: true)], animation: .default)
    private var trips: FetchedResults<Trip>
    
    @State var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 53.5461, longitude: -113.4937), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    @State var routeCoords: [CLLocationCoordinate2D] = []
    
    var screenWidth = UIScreen.main.bounds.width
    
    var notes = ""
    
    var tagColours = [
        0: Color(red: 47/255, green: 72/255, blue: 88/255),
        1: Color(red: 51/255, green: 101/255, blue: 138/255),
        2: Color(red: 134/255, green: 187/255, blue: 216/255),
        4: Color(red: 246/255, green: 174/255, blue: 45/255),
        5: Color(red: 242/255, green: 100/255, blue: 25/255),
    ]
    
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
    
    var body: some View {
        // link to detail view when preview is pressed
        NavigationLink(destination: TripDetailView(trip: trip)) { // built from the trip itself so it opens with current saved values
            
            ZStack(alignment: .center) {
                Rectangle()
                    .foregroundColor(colorScheme == .dark ? Color("TripiDark") : Color.white)
                    .frame(width: previewStyle == .compact ? 154 : screenWidth*0.87, height: previewStyle == .compact ? 256 : 158)
                    .cornerRadius(25)
                    .shadow(color: .primary.opacity(0.025), radius: 7, x: 10, y: 10)
                    .shadow(color: .primary.opacity(0.025), radius: 7, x: -5, y: -5)
                
                // expanded preview style for TripBrowserView
                if previewStyle == .expanded {
                    HStack(alignment: .center) {

                        // map with overlays
                        StaticPolylineMap(region: $region, routeCoordinates: $routeCoords, trip: trip)
//                        PolylineMap(region: $region, routeCoordinates: $routeCoords, isTracking: false, edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
                            .frame(width: previewStyle == .compact ? 134 : 129, height: previewStyle == .compact ? 161 : 145)
                            .cornerRadius(17)
                            .shadow(color: .primary.opacity(0.05), radius: 20, x: 10, y: 10)
                            .shadow(color: .primary.opacity(0.05), radius: 20, x: -5, y: -5)
                                                
                    // summarized metrics
                        VStack(alignment: .leading, spacing: 0) {
                            Text(date)
                                .font(.custom("Gilroy", size: 16))
                                .foregroundColor(.primary)
                            Text("\(formatTime(date:starTime)) - \(formatTime(date:endTime))")
                                .font(.custom("Gilroy", size: 12))
                                .foregroundColor(.primary)

                            Text("\(String(format:"%.1f", unitFormatter.formatDistance(distance: distance, selectedUnits: selectedUnits)) + (selectedUnits == "metric" ? " km" : " mi")) · \(unitFormatter.formatReimbursable(amount: trip.amountReimbursable))")
                                .font(.custom("Gilroy", size: 12))
                                .foregroundColor(color)
                            // dipslay tags in expanded view
                            WrappingHStack(trip.tagsArray, id: \.self, spacing: .constant(5), lineSpacing: 5) { tag in
                                Tag(name: tag.wrappedName, colour: tag.displayColour, isSmall: true)
                                    .foregroundColor(.primary)
                                    .fixedSize()
                            }
                                .frame(height: 48, alignment: .top)
                                .padding(.vertical, 5)
                            .clipped()
                            .id(tagID)
//                            .background(Color.red)


                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(Font.system(size: 22, weight: .black))
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.vertical, 15)
                        .padding(.horizontal, 10)
                        

                    }
                    .padding(.vertical)
                    .frame(width: screenWidth*0.833)
//                    .background(Color.red)
                    
                    
                } else {
                    // compact layout for RecentTrips
                    VStack(alignment: .center) {
                        // map with overlays
                        StaticPolylineMap(region: $region, routeCoordinates: $routeCoords, trip: trip)
//                        PolylineMap(region: $region, routeCoordinates: $routeCoords, isTracking: false, edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
                            .frame(width: previewStyle == .compact ? 134 : 129, height: previewStyle == .compact ? 161 : 138)
                            .cornerRadius(15)
                            .shadow(color: .primary.opacity(0.05), radius: 20, x: 10, y: 10)
                            .shadow(color: .primary.opacity(0.05), radius: 20, x: -5, y: -5)
                            .padding(.top, 5)
                        
                        // summarized metrics
                        VStack(alignment: .leading) {
                            // spacer keeps the chevron pinned to the card edge regardless of distance length
                            HStack(spacing: 4) {
                                Text(String(format:"%.1f", unitFormatter.formatDistance(distance: distance, selectedUnits: selectedUnits)) + (selectedUnits == "metric" ? " km" : " mi"))
                                    .font(.custom("Gilroy", size: 22))
                                    .monospacedDigit()
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                                Spacer(minLength: 0)
                                Image(systemName: "chevron.right")
                                    .font(Font.system(size: 15, weight: .black))
                            }
                            .foregroundColor(.primary)
                            
                            
                            Text(date)
                                .font(.custom("Gilroy", size: 12))
                                .foregroundColor(.primary)
                            
                            // display only primary tag (if one exists) and reimbursement amount
                            if let firstTag = trip.tagsArray.first {
                                Text("\(firstTag.wrappedName.uppercased()) · \(unitFormatter.formatReimbursable(amount: trip.amountReimbursable))")
                                    .font(.custom("Gilroy", size: 15))
                                    .foregroundColor(color)
                            }
                            
                            
                        }
                        .padding(.horizontal, 5)
                        Spacer()
                        
                    }.padding(5)
                }
            }
            .frame(width: previewStyle == .expanded ? screenWidth*0.87 : 154, height: previewStyle == .expanded ? 158 : 256)
            .onChange(of: tags) { _, newValue in
                tagID = newValue
            }
            .onAppear {
                tagID = NSOrderedSet()
            }
        }
//        .contextMenu {
//            Button {
//                PersistenceController.shared.delete(trip: trip)
//            } label: {
//                Label("Delete Trip", systemImage: "trash")
//            }

//        }
    }
}
