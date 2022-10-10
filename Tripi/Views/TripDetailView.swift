//
//  TripDetailView.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-08-31.
//

import SwiftUI
import MapKit

struct TripDetailView: View {
    @State var distance: Double
    @State var time: String
    @State var avgSpeed: Double
    @State var startTime: Date
    @State var endTime: Date
    @State var notes: String
    @State var region: MKCoordinateRegion
    @State var routeCoords: [CLLocationCoordinate2D]
    
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
        ZStack(alignment: .topLeading) {
            PolylineMap(region: $region, routeCoordinates: $routeCoords, isTracking: false)
                .edgesIgnoringSafeArea(.all)
                .frame(height: 300)
            VStack {
                Spacer()
                    .frame(height: 150)
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .foregroundColor(Color("Background"))
                        .cornerRadius(50, corners: [.topLeft, .topRight])
                        .shadow(color: .primary.opacity(0.15), radius: 20, x: -5, y: -5)
                        .edgesIgnoringSafeArea(.all)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Trip Summary")
                            .font(.custom("Gilroy", size: 32))
                            .padding(.leading, 30)
                            .padding(.top, 40)
                        Text(formatTime(date: startTime)+" - "+formatTime(date: endTime)+" | "+formatDay(date: startTime))
                            .font(.custom("Gilroy", size: 15))
                            .foregroundColor(.gray)
                            .padding(.leading, 30)
                        
                        HStack(spacing: 32) {
                            Metric(data: String(format:"%.1f", distance), descriptor: "TOTAL KM")
                            Metric(data: time, descriptor: "MINUTES")
                            Metric(data: String(format:"%.0f", avgSpeed), descriptor: "AVG KM/H")
                        }
                        .padding(30)
                        Text("Tags")
                            .font(.custom("Gilroy", size: 24))
                            .padding(.leading, 30)
//                            Rectangle()
//                                .foregroundColor(Color(.systemGray5))
//                                .frame(width: 330, height: 250)
//                                .cornerRadius(25)
                        Button {
                            
                        } label: {
                            ZStack(alignment: .center) {
                                Rectangle()
                                    .frame(width: 80, height: 30)
                                    .cornerRadius(15)
                                    .foregroundColor(Color(.systemGray5))

                                HStack {
                                    Image(systemName: "plus")
                                    Text("New")
                                }
                                    .foregroundColor(Color.primary)
                                    .font(.custom("Gilroy", size: 16))
                            }
                            .padding(.top, 15)
                            .padding(.leading, 30)
                        }
                        
                        Text("Notes")
                            .font(.custom("Gilroy", size: 24))
                            .padding(.vertical, 15)
                            .padding(.leading, 30)
                        
                        ZStack(alignment: .top) {
                            Rectangle()
                                .cornerRadius(20)
                                .foregroundColor(Color(.systemGray5))
                                .padding(.horizontal, 30)
                                .frame(height: 150)
                            TextEditor(text: $notes)
                                .scrollContentBackground(.hidden)
                                .scrollDisabled(true)
                                .padding(.horizontal, 40)
                                .padding(.top, 15)
                                .frame(height: 150)
                        }

                    }

                }
            }
        }
    }
}

struct TripDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TripDetailView(distance: 200, time: "22:12", avgSpeed: 102, startTime: Date(), endTime: Date(), notes: "", region: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), routeCoords: [])
    }
}
