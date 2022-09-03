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
                    Text("Trip Summary")
                        .font(.custom("Gilroy", size: 32))
                        .padding(30)
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
