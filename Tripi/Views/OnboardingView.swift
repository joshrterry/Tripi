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
    @State private var motionStatus: PermissionStatus = .notDetermined
    @State private var notificationStatus: PermissionStatus = .notDetermined
    @State private var motionManager = CMMotionActivityManager() // held so the permission query isn't cancelled when it goes out of scope
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    
    enum PermissionStatus {
        case notDetermined, granted, denied
        
        var iconName: String {
            switch self {
            case .notDetermined: return "circle"
            case .granted: return "checkmark.circle"
            case .denied: return "xmark.circle"
            }
        }
    }
    
    private var locationStatus: PermissionStatus {
        switch routeManager.locationAuthorization {
        case .notDetermined: return .notDetermined
        case .authorizedWhenInUse, .authorizedAlways: return .granted
        default: return .denied
        }
    }
    
    // every permission has been asked for; denying one shouldn't block the user from continuing
    private var allRequested: Bool {
        locationStatus != .notDetermined && motionStatus != .notDetermined && notificationStatus != .notDetermined
    }
    
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
                        permissionRow("Allow Location Services", status: locationStatus) {
                            routeManager.locationManagerConfig()
                        }
                        
                        permissionRow("Allow Motion Updates", status: motionStatus) {
                            requestMotion()
                        }
                        
                        permissionRow("Allow Notifications", status: notificationStatus) {
                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                if let error = error {
                                    print(error.localizedDescription) // print errors to console
                                }
                                DispatchQueue.main.async {
                                    withAnimation {
                                        notificationStatus = success ? .granted : .denied
                                    }
                                }
                            }
                        }
                    } footer: {
                        if [locationStatus, motionStatus, notificationStatus].contains(.denied) {
                            Text("Some features won't work without these permissions. Tap a denied item to open Settings.")
                        }
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
                        }.disabled(!allRequested)
                            .listRowBackground(Color.secondary.opacity(0.1))
                        
                    }
                    
                }
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                
            }.padding(.vertical, 50)
                .padding(.horizontal, 20)
        }
        .animation(.default, value: locationStatus)
        .onAppear {
            refreshStatuses()
        }
        // pick up changes made in the Settings app
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            refreshStatuses()
        }
    }
    
    private func permissionRow(_ title: String, status: PermissionStatus, request: @escaping () -> Void) -> some View {
        Button {
            if status == .denied {
                // the system prompt only appears once, so send the user to Settings instead
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } else {
                request()
            }
        } label: {
            HStack {
                Image(systemName: status.iconName)
                    .foregroundColor(status == .denied ? .red : nil)
                    .contentTransition(.symbolEffect(.replace))
                Text(title)
            }
        }
        .disabled(status == .granted)
        .listRowBackground(Color.secondary.opacity(0.1))
    }
    
    private func requestMotion() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            motionStatus = .denied
            return
        }
        // querying history triggers the permission prompt and calls back once the user has answered
        motionManager.queryActivityStarting(from: Date().addingTimeInterval(-60), to: Date(), to: .main) { _, _ in
            withAnimation {
                motionStatus = Self.motionPermission()
            }
        }
    }
    
    private static func motionPermission() -> PermissionStatus {
        switch CMMotionActivityManager.authorizationStatus() {
        case .notDetermined: return .notDetermined
        case .authorized: return .granted
        default: return .denied
        }
    }
    
    private func refreshStatuses() {
        motionStatus = Self.motionPermission()
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let status: PermissionStatus
            switch settings.authorizationStatus {
            case .notDetermined: status = .notDetermined
            case .denied: status = .denied
            default: status = .granted
            }
            DispatchQueue.main.async {
                notificationStatus = status
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
