//
//  NavigationBar.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-01.
//

import SwiftUI

struct NavigationBar: View {
    
    enum Sheet: String, Identifiable {
        case settingsView, exportView
        var id: String { rawValue }
    }
    
    @State var showingButttons = true
    var title = ""
    @Binding var hasScrolled: Bool
    @State private var presentedSheet: Sheet?
    @EnvironmentObject var routeManager: RouteManager

    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
            
            // amimated navbar header (dependant on value passed to view)
            Text(title)
                .animatableFont(size: hasScrolled ? 22 : 34)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding(.top, 20)
                .offset(y: hasScrolled ? -4 : 0)
            
            if showingButttons {
                // display exportwindow and settingsview buttons in nav bar
                HStack(spacing: 16) {
                    // button for export view
                    Button {
                        presentedSheet = .exportView
                    } label: {
                        Image(systemName: "square.and.arrow.up.circle")
                            .font(.body.weight(.bold))
                            .frame(width: 36, height: 36)
                            .foregroundColor(routeManager.trackingState == .active ? .secondary.opacity(0.4) : .secondary)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .strokeStyle(cornerRadius: 14)
                    }.disabled(routeManager.trackingState == .active ? true : false)
                    // button for settings view
                    Button {
                        presentedSheet = .settingsView
                    } label: {
                        Image(systemName: "gear")
                            .font(.body.weight(.bold))
                            .frame(width: 36, height: 36)
                            .foregroundColor(.secondary)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .strokeStyle(cornerRadius: 14)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 20)
                .padding(.top, 20)
                .offset(y: hasScrolled ? -4 : 0)
            }
        }
        // open exportwindow or settingsview as modal when selected
        .sheet(item: $presentedSheet, content: { sheet in
            switch sheet {
            case .exportView:
                ExportWindow()
            case .settingsView:
                SettingsView()
            }
        })
        .frame(height: hasScrolled ? 70 : 80)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
