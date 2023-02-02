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
    @State var tags: [String]
    @State var descriptor = ""
    @Environment(\.dismiss) private var dismiss
    @AppStorage("showingTabBar") var showingTabBar: Bool = true
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \UserTag.dateCreated, ascending: true)], animation: .default)
    private var globalTags: FetchedResults<UserTag>
    
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
        ZStack(alignment: .topLeading) {
            PolylineMap(region: $region, routeCoordinates: $routeCoords, isTracking: false, edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0))
                .edgesIgnoringSafeArea(.all)
                .frame(height: 300)
            ScrollView {
                VStack {
                    Spacer()
                        .frame(height: 250)
                    ZStack(alignment: .topLeading) {
                        Rectangle()
                            .foregroundColor(Color("Background"))
                            .cornerRadius(50, corners: [.topLeft, .topRight])
                            .shadow(color: .primary.opacity(0.15), radius: 20, x: -5, y: -5)
                            .frame(height: 800)
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Group {
                                HStack {
                                    Text("Trip Summary")
                                        .font(.custom("Gilroy", size: 32))
                                    Spacer()
                                    
                                    
                                    Menu {
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
                            }
                            
                            Group {
                                HStack(alignment: .top) {
                                    Menu {
                                        ForEach(globalTags, id: \.self) { tag in
                                            Button {
//                                                tags.append(Tag())
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
                                    ForEach(tags, id: \.self) { tag in
                                        Tag(name: tag.capitalized, colour: tagColours.values.randomElement()!)
                                            .contextMenu {
                                                if tags.count > 1 {
                                                    Button {
                                                        if let index = tags.firstIndex(of: tag) {
                                                            tags.remove(at: index)
                                                        }
                                                    } label: {
                                                        Label("Delete Tag", systemImage: "trash")
                                                    }
                                                }
                                            }
                                    }
                                    
                                }
                            }
                            .padding(.top, 15)
                            
                            
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
            }.toolbarBackground(.hidden, for: .navigationBar)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: BackButton(dismiss: self.dismiss))
                .edgesIgnoringSafeArea(.all)
        }.onDisappear {
            uploadChanges()
            showingTabBar = true
        }
        .onAppear {
            showingTabBar = false
        }
    }
    
    func uploadChanges() {
        trip.tags = tags
        trip.notes = notes
        PersistenceController.shared.save()
    }
}

struct TripDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TripDetailView(trip: Trip(), distance: 200, time: "22:12", avgSpeed: 102, startTime: Date(), endTime: Date(), notes: "", region: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), routeCoords: [], tags: [])
    }
}
