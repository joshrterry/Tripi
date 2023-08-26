//
//  SettingsView.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-09-05.
//

import SwiftUI
import UserNotifications
import CoreLocation

struct SettingsView: View {
    
    @State var hasScrolled = false
    @AppStorage("selectedUnits") var selectedUnits = "metric"
    @AppStorage("selectedAutonomy") var selectedAutonomy = 0
    @State var showingAlert = false
    private let numberFormatter: NumberFormatter
    @State var footerText = ""
    @Environment(\.dismiss) var dismiss
    @State var notificationsEnabled = false
    @State var locationAlways = false
    @State var locationInUse = false
    @EnvironmentObject var routeManager: RouteManager
    
    
    let current = UNUserNotificationCenter.current()
    
    init() {
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.maximumFractionDigits = 2
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                Color("Background").ignoresSafeArea()
                
                Form {
                    // toggle between metric and imperial units
                    Picker(selection: $selectedUnits) {
                        Text("Metric").tag("metric")
                        Text("Imperial").tag("imperial")
                        
                    } label: {
                        HStack {
                            Image(systemName: "number.square.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.indigo)
                            Text("Measurement System")
                                .foregroundColor(.primary)
                            
                            
                        }
                    }.pickerStyle(.inline)
                    
                    // open tag sort view on new page
                    NavigationLink(destination: TagSort()) {
                        HStack {
                            Image(systemName: "tag.square.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.green)
                            Text("Customize Tags")
                                .foregroundColor(.primary)
                            
                        }
                    }
                    Section(footer: Text(footerText)) {
                        ZStack {
                            scrollDetection
                            // autonomy level preference
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "bolt.square.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.orange)
                                    Text("Autonomy level")
                                        .foregroundColor(.primary)
                                }
                                Picker("Autonomy Level", selection: $selectedAutonomy) {
                                    Text("None").tag(0)
                                    Text("Notify").tag(1)
                                    Text("Auto").tag(2)
                                    
                                }.pickerStyle(.segmented)
                            }
                        }
                        
                    }
                    // change footer text with change of selected autonomy level
                    .onReceive(selectedAutonomy.description.publisher) { _ in
                        switch selectedAutonomy {
                        case 0:
                            footerText = "Manual control - Trip must be stopped from within the application."
                        case 1:
                            footerText = "Notification mode - Alerts will be sent to remind you to end your trip when it seems like you've stopped driving."
                        case 2:
                            footerText = "Fully automatic - Trips will be automatically paused without any user intervention. Note: You can still manually resume the trip through the app."
                        default:
                            footerText = ""
                        }
                    }
                    
//                    if !notificationsEnabled {
//                        // button to manually authorize notifications
//                        Section {
//                            Button {
//                                current.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
//                                    if success {
//                                    } else if let error = error {
//                                        print(error.localizedDescription) // print errors to console
//                                    }
//                                }
//                            } label: {
//                                HStack {
//                                    Image(systemName: "bell.square.fill")
//                                        .font(.system(size: 28))
//                                        .foregroundColor(.red)
//                                    Text("Authorize Notifications")
//                                        .foregroundColor(.primary)
//                                }
//                            }
//                        }
//                    }
                   
                    
                    Section {
                        Link(destination: URL(string: "https://tripi.codeflyt.com/privacy")!) {
                            HStack {
                                Image(systemName: "hand.raised.square.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.blue)
                                Text("Privacy Policy")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    
                    
                }
                .scrollContentBackground(.hidden)
                .coordinateSpace(name: "scroll")
                .safeAreaInset(edge: .top, content: {
                    Color.clear.frame(height: 70)
                })
                .overlay(NavigationBar(showingButttons: false, title: "Settings", hasScrolled: $hasScrolled))
                .offset(y: 40)
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            Button("Done", action: dismiss.callAsFunction).padding(25)
                        }
                        Spacer()
                    }
                )
                .navigationBarHidden(true)
                
            }
        }
//        .onAppear {
//            current.getNotificationSettings { settings in
//                if settings.authorizationStatus == .authorized {
//                    notificationsEnabled = true
//                } else {
//                    notificationsEnabled = false
//                }
//            }
//            switch routeManager.locationManager.authorizationStatus {
//            case .authorizedAlways:
//                locationAlways = true
//                locationInUse = true
//            case .authorizedWhenInUse:
//                locationInUse = true
//            default:
//                locationAlways = false
//                locationInUse = false
//            }
//
//        }
    }
    
    var scrollDetection: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: ScrollPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)
        }
        .frame(height: 0)
        .onPreferenceChange(ScrollPreferenceKey.self, perform: { value in
            withAnimation(.easeInOut) {
                if value < 0 {
                    hasScrolled = true
                } else {
                    hasScrolled = false
                }
            }
        })
    }
}
