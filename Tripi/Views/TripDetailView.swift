//
//  TripDetailView.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-08-31.
//

import SwiftUI
import MapKit

struct TripDetailView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))), interactionModes: [])
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
                        Text("10:23 AM - 10:55 AM | Sept 3, 2022")
                            .font(.custom("Gilroy", size: 15))
                            .foregroundColor(.gray)
                            .padding(.leading, 30)
                        
                        HStack(spacing: 32) {
                            Metric(data: "54.3", descriptor: "TOTAL KM")
                            Metric(data: "23:10", descriptor: "MINUTES")
                            Metric(data: "93", descriptor: "AVG KM/H")
                        }
                        .padding(30)
                        HStack {
                            Spacer()
                            Rectangle()
                                .foregroundColor(Color(.systemGray5))
                                .frame(width: 330, height: 250)
                                .cornerRadius(25)
                            Spacer()
                        }

                    }

                }
            }
        }
    }
}

struct TripDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TripDetailView()
    }
}
