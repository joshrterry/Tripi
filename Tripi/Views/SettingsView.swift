//
//  SettingsView.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-09-05.
//

import SwiftUI

struct SettingsView: View {
    
    @State var hasScrolled = false
    @AppStorage("reimbursementAmount") var reimbursementAmount = 1.00

    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
                Text("Settings")
                List {
                    ZStack {
                        scrollDetection
                        Stepper("Reimbursement amount: $\(String(format: "%.2f", reimbursementAmount)) / km", value: $reimbursementAmount, in: 0...1.0, step: 0.05)
                    }

                }
            .coordinateSpace(name: "scroll")
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 50)
            })

            .overlay(NavigationBar(title: "Settings", hasScrolled: $hasScrolled))
            .offset(y: 40)
            .navigationBarHidden(true)
        }
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
