//
//  NavigationBar.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-07-01.
//

import SwiftUI

struct NavigationBar: View {
    
    @State var showingButttons = true
    var title = ""
    @Binding var hasScrolled: Bool
    @State private var showingSettings = false
    @State private var showingExport = false
    
    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
            
            Text(title)
                .animatableFont(size: hasScrolled ? 22 : 34)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding(.top, 20)
                .offset(y: hasScrolled ? -4 : 0)
            
            if showingButttons {
                HStack(spacing: 16) {
                    Button {
                        showingExport.toggle()
                    } label: {
                        Image(systemName: "square.and.arrow.up.circle")
                            .font(.body.weight(.bold))
                            .frame(width: 36, height: 36)
                            .foregroundColor(.secondary)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .strokeStyle(cornerRadius: 14)
                    }
                    Button {
                        showingSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .font(.body.weight(.bold))
                            .frame(width: 36, height: 36)
                            .foregroundColor(.secondary)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .strokeStyle(cornerRadius: 14)
                    }
                    .sheet(isPresented: $showingSettings) {
                        SettingsView()
                    }
                    .sheet(isPresented: $showingExport) {
                        ExportWindow()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 20)
                .padding(.top, 20)
                .offset(y: hasScrolled ? -4 : 0)
            }
        }
        .frame(height: hasScrolled ? 70 : 80)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar(title: "Title", hasScrolled: .constant(false))
    }
}
