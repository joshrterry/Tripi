//
//  Preview.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-01.
//

import SwiftUI
import MapKit

struct Preview: View {
    @State var previewStyle: LayoutStyle = .compact

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var routeManager: RouteManager
    @AppStorage("reimbursementAmount") var reimbursementAmount = 1.00
    
    var trip: Trip
    var distance = 0.0
    var date = ""
    var color = Color.primary
    
    var time = ""
    var avgSpeed = 0.0
    var starTime: Date
    var endTime: Date
    
    var tags = [""]
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Trip.endTimestamp, ascending: true)], animation: .default)
    private var trips: FetchedResults<Trip>
    
    @State var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 53.5461, longitude: -113.4937), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    @State var routeCoords: [CLLocationCoordinate2D] = []
    
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
        NavigationLink(destination: TripDetailView(trip: trip, distance: distance, time: time, avgSpeed: avgSpeed, startTime: starTime, endTime: endTime, notes: notes, region: region, routeCoords: routeCoords, tags: tags)) {

            ZStack(alignment: .center) {
                Rectangle()
                    .foregroundColor(colorScheme == .dark ? Color("TripiDark") : Color.white)
                    .frame(width: previewStyle == .compact ? 154 : 337, height: previewStyle == .compact ? 256 : 151)
                    .cornerRadius(25)
                    .shadow(color: .primary.opacity(0.025), radius: 7, x: 10, y: 10)
                    .shadow(color: .primary.opacity(0.025), radius: 7, x: -5, y: -5)
                
                if previewStyle == .expanded {
                    HStack(alignment: .center) {
                        PolylineMap(region: $region, routeCoordinates: $routeCoords, isTracking: false, edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
                            .frame(width: previewStyle == .compact ? 134 : 129, height: previewStyle == .compact ? 161 : 138)
                            .cornerRadius(15)
                            .shadow(color: .primary.opacity(0.05), radius: 20, x: 10, y: 10)
                            .shadow(color: .primary.opacity(0.05), radius: 20, x: -5, y: -5)
                                                
                        VStack(alignment: .leading) {
                            Text(date)
                                .font(.custom("Gilroy", size: 18))
                                .foregroundColor(.primary)
                            Text("\(formatTime(date:starTime)) - \(formatTime(date:endTime))")
                                .font(.custom("Gilroy", size: 12))
                                .foregroundColor(.primary)
                            
//                            HStack(spacing: 40) {
//                                Text(String(format:"%.1f", distance)+" km")
//                                    .font(.custom("Gilroy", size: 22))
//                                Image(systemName: "chevron.right")
//                                    .font(Font.system(size: 15, weight: .black))
//                            }
                            Text("\(String(format:"%.1f", distance)+" km") · $\(String(format: "%.2f", reimbursementAmount * distance))")
                                .font(.custom("Gilroy", size: 12))
                                .foregroundColor(color)
                            
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    Tag(name: tag.capitalized, colour: tagColours.values.randomElement()!)
                                        .foregroundColor(.primary)
                                }
                            }
                     
                            HStack {
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(Font.system(size: 24, weight: .black))
                                    .foregroundColor(.primary)
                            }
                            
                        }
                        .frame(width: 180)
                    }
                } else {
                        VStack(alignment: .center) {
                            PolylineMap(region: $region, routeCoordinates: $routeCoords, isTracking: false, edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
                                .frame(width: previewStyle == .compact ? 134 : 129, height: previewStyle == .compact ? 161 : 138)
                                .cornerRadius(15)
                                .shadow(color: .primary.opacity(0.05), radius: 20, x: 10, y: 10)
                                .shadow(color: .primary.opacity(0.05), radius: 20, x: -5, y: -5)
                                .padding(.top, 5)

                            VStack(alignment: .leading) {
                                HStack(spacing: 40) {
                                    Text(String(format:"%.1f", distance)+" km")
                                        .font(.custom("Gilroy", size: 22))
                                    Image(systemName: "chevron.right")
                                        .font(Font.system(size: 15, weight: .black))
                                }
                                .foregroundColor(.primary)

                                
                                Text(date)
                                    .font(.custom("Gilroy", size: 12))
                                    .foregroundColor(.primary)

                                Text("\(tags[0].uppercased()) · $\(String(format: "%.2f", reimbursementAmount * distance))")
                                    .font(.custom("Gilroy", size: 15))
                                    .foregroundColor(color)
                                
                            }
                            .padding(.horizontal, 5)

                        }
                    }

               
            }
            .contextMenu {
                Button {
                    PersistenceController.shared.delete(trip: trip)
                } label: {
                    Label("Delete Trip", systemImage: "trash")
                }
            }
        }
    }
}

struct Preview_Previews: PreviewProvider {
    static var previews: some View {
        Preview(trip: Trip(), distance: 22.3, date: "June 24 | 8:32 AM", starTime: Date(), endTime: Date())
    }
}
