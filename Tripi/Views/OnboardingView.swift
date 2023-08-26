//
//  OnboardingView.swift
//  Tripi
//
//  Created by Joshua Terry on 2023-08-20.
//

import SwiftUI
import CoreMotion

struct OnboardingView: View {
    @EnvironmentObject var routeManager: RouteManager
    @State var allowedLocation = false
    @State var allowedMotion = false
    @State var allowedNotifications = false
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    
    
    var body: some View {
        ZStack {
            VStack {
                Image("tripimono")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                Text("Let's get started!")
                    .font(.custom("Gilroy", size: 38))
                    .foregroundColor(.primary)
                List {
                    
                    Section {
                        Button {
                            routeManager.locationManagerConfig()
                            allowedLocation = true
                        } label: {
                            HStack {
                                Image(systemName:allowedLocation ? "checkmark.circle" : "circle")
                                Text("Allow Location Services")
                            }
                            
                        }.disabled(allowedLocation)
                            .listRowBackground(Color.secondary.opacity(0.1))
                        
                        Button {
                            let testMotion = CMMotionActivityManager()
                            if CMMotionActivityManager.isActivityAvailable() {
                                testMotion.startActivityUpdates(to: OperationQueue.main) { (motion) in
                                    testMotion.stopActivityUpdates()
                                }
                            }
                            
                            allowedMotion = true
                        } label: {
                            HStack {
                                Image(systemName:allowedMotion ? "checkmark.circle" : "circle")
                                Text("Allow Motion Updates")
                            }
                            
                        }.disabled(allowedMotion)
                            .listRowBackground(Color.secondary.opacity(0.1))
                        
                        Button {
                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                if success {
                                } else if let error = error {
                                    print(error.localizedDescription) // print errors to console
                                }
                            }
                            allowedNotifications = true
                        } label: {
                            HStack {
                                Image(systemName:allowedNotifications ? "checkmark.circle" : "circle")
                                Text("Allow Notifications")
                            }
                            
                        }.disabled(allowedNotifications)
                            .listRowBackground(Color.secondary.opacity(0.1))
                    }
                    
                    Section {
                        Button {
                            withAnimation {
                                hasOnboarded.toggle()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Let's Go")
                                Image(systemName: "arrowshape.right")
                                Spacer()
                            }
                        }.disabled(!(allowedMotion && allowedNotifications && allowedLocation))
                            .listRowBackground(Color.secondary.opacity(0.1))
                        
                    }
                    
                }
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                
            }.padding(.vertical, 50)
                .padding(.horizontal, 20)
        }
        
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
