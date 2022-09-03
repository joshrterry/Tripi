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

    var distance = ""
    var date = ""
    var category = ""
    var color = Color.primary
    
    var body: some View {
        
            NavigationLink(destination: TripDetailView()) {

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
                    Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))), interactionModes: [])
                        .frame(width: 134, height: 161)
                        .cornerRadius(15)
                        .shadow(color: .primary.opacity(0.05), radius: 20, x: 10, y: 10)
                        .shadow(color: .primary.opacity(0.05), radius: 20, x: -5, y: -5)
                        .padding(.top, 10)

                    VStack(alignment: .leading) {
                        HStack(spacing: 40) {
                            Text("\(distance) km")
                                .font(.custom("Gilroy", size: 22))
                            Image(systemName: "chevron.right")
                                .font(Font.system(size: 15, weight: .black))
                        }
                        .foregroundColor(.primary)

                        
                        Text(date)
                            .font(.custom("Gilroy", size: 12))
                            .foregroundColor(.primary)

                        Text(category.uppercased())
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
        Preview(distance: "36.7", date: "June 24 | 8:32 AM", category: "business · $12.76")
    }
}
