//
//  SettingsView.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-09-05.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    
    @State var hasScrolled = false
    @AppStorage("reimbursementAmount") var reimbursementAmount = 1.00
    @AppStorage("selectedUnits") var selectedUnits = "metric"
    @AppStorage("selectedAutonomy") var selectedAutonomy = 0
    @State var showingAlert = false
    private let numberFormatter: NumberFormatter
    @State var footerText = ""
    
    init() {
      numberFormatter = NumberFormatter()
      numberFormatter.numberStyle = .currency
      numberFormatter.maximumFractionDigits = 2
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").ignoresSafeArea()
                    Form {
//                        ZStack {
//                                Button {
//                                    showingAlert = true
//                                } label: {
//                                HStack {
//                                    Image(systemName: "dollarsign.square.fill")
//                                        .font(.system(size: 28))
//                                        .foregroundColor(.green)
//                                    Text("Reimbursement Rate")
//                                        .foregroundColor(.primary)
//                                    Spacer()
//                                    Text(String(format: "%.2f", reimbursementAmount))
//                                        .foregroundColor(.secondary)
//                                    Image(systemName: "chevron.right")
//                                        .foregroundColor(.secondary)
//                                }
//                                }.alert("Enter reimbursement amount:", isPresented: $showingAlert) {
//                                    TextField("$0.00", value: $reimbursementAmount, formatter: numberFormatter)
//                                        .keyboardType(.decimalPad)
//                                }
                                

                            

    //                        Stepper("Reimbursement amount: $\(String(format: "%.2f", reimbursementAmount)) / km", value: $reimbursementAmount, in: 0...1.0, step: 0.05)
//                        }
                        
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

//                        NavigationLink(destination:
//                            List {
//                            HStack {
//                                Spacer()
//                                Picker("Units", selection: $selectedUnits, content: {
//                                    Text("Metric").tag("metric")
//                                    Text("Imperial").tag("imperial")
//                                })
//                            }
//
//                        }
//
//                        ) {
//                        }

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
                        .onReceive(selectedAutonomy.description.publisher) { _ in
                            switch selectedAutonomy {
                            case 0:
                                footerText = "Manual control - Trips must be started and stopped from within the application."
                            case 1:
                                footerText = "Notification mode - Alerts will be sent when it seems like you are driving, and you will be prompted to end the trip when stopped."
                            case 2:
                                footerText = "Fully automatic - Trips will be stopped and started without any user intervention. Note: This may result in unintentional trips being tracked."
                            default:
                                footerText = ""
                            }
                        }
                        
                        Section {
                            Button {
                                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                    if success {
                                    } else if let error = error {
                                        print(error.localizedDescription)
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "bell.square.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.red)
                                    Text("Authorize Notifications")
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
                .navigationBarHidden(true)
            }
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
