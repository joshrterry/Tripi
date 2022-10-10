//
//  Preview.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-01.
//

import SwiftUI
import MapKit

struct Preview: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var routeManager: RouteManager
    @AppStorage("reimbursementAmount") var reimbursementAmount = 1.00
    
    var distance = 0.0
    var date = ""
    var color = Color.primary
    
    var time = ""
    var avgSpeed = 0.0
    var starTime: Date
    var endTime: Date
    
    var expenseTag = ""
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Trip.endTimestamp, ascending: true)], animation: .default)
    private var trips: FetchedResults<Trip>
    
    @State var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 53.5461, longitude: -113.4937), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    @State var routeCoords: [CLLocationCoordinate2D] = []
    
    var body: some View {
        
        NavigationLink(destination: TripDetailView(distance: distance, time: time, avgSpeed: avgSpeed, startTime: starTime, endTime: endTime, notes: "", region: region, routeCoords: routeCoords)) {

            ZStack(alignment: .top) {
                Rectangle()
                    .foregroundColor(colorScheme == .dark ? Color("TripiDark") : Color.white)
                    .frame(width: 154, height: 256)
                    .cornerRadius(25)
                    .shadow(color: .primary.opacity(0.025), radius: 7, x: 10, y: 10)
                    .shadow(color: .primary.opacity(0.025), radius: 7, x: -5, y: -5)
                
                VStack(alignment: .center) {
    //                Rectangle()
    //                    .foregroundColor(.gray)
                    PolylineMap(region: $region, routeCoordinates: $routeCoords, isTracking: false)
                        .frame(width: 134, height: 161)
                        .cornerRadius(15)
                        .shadow(color: .primary.opacity(0.05), radius: 20, x: 10, y: 10)
                        .shadow(color: .primary.opacity(0.05), radius: 20, x: -5, y: -5)
                        .padding(.top, 10)

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

                        Text("\(expenseTag.uppercased()) · $\(String(format: "%.2f", reimbursementAmount * distance))")
                            .font(.custom("Gilroy", size: 15))
                            .foregroundColor(color)
                        
                    }
                    .padding(.horizontal, 5)

                }
               
            }
        }
    }
}

struct Preview_Previews: PreviewProvider {
    static var previews: some View {
        Preview(distance: 22.3, date: "June 24 | 8:32 AM", starTime: Date(), endTime: Date())
    }
}
