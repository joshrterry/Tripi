//
//  TabBar.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-01.
//

import SwiftUI

struct TabBar: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("selectedTab") var selectedTab: Tab = .home
    @EnvironmentObject var routeManager: RouteManager
    
    var body: some View {
        VStack {
            Spacer()
            ZStack(alignment: .top) {
                
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 90)
                    .foregroundColor(colorScheme == .dark ? Color("TripiDark") : .white)
                    .cornerRadius(30)
                    .shadow(color: .primary.opacity(0.05), radius: 7, x: -5, y: -5)
                HStack(spacing: 45) {
                    Group {
                        Button {
                            selectedTab = .home
                        } label: {
                            Image(systemName: "house.fill")
                                .foregroundColor(.primary)
                        }
                        ZStack {
                            Circle()
                                .foregroundColor(colorScheme == .dark ? Color("TripiDark") : .white)
                                .frame(width: 62, height: 62)
                                .shadow(color: .primary.opacity(0.1), radius: 20, x: 10, y: 10)
                                .shadow(color: .primary.opacity(0.1), radius: 20, x: -5, y: -5)
                                
                            Button {
                                if selectedTab == .route {
                                    routeManager.toggleTrip()
                                } else {
                                    selectedTab = .route

                                }
                                print(routeManager.trackingState)

                            } label: {
                                Image(selectedTab == .route ? "go_icon" : "tripimono")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 45, height: 45)
                                    .foregroundColor(.black)
                                    .font(.system(size: 50))
                            }
                        }
                        .offset(y: -10)

                        Button {
                            selectedTab = .trips
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(.secondary)
                        }
                    }
                    .font(.system(size: 24, weight: .bold))
                }

            }
        }
        .edgesIgnoringSafeArea(.all)

    }
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar()
    }
}
