//
//  ActivityManager.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-11-17.
//  Billugha was here ;)

// http://www.wepstech.com/coremotion-in-ios-swift-5/

import Foundation
import CoreMotion
import UserNotifications
import SwiftUI

class ActivityManager: NSObject {
//    let routeManager: RouteManager
    

    var activityManager: CMMotionActivityManager!
    let notificationManager = NotificationManager()
    
    func startMotionUpdates() {
        // creates a new instance of CMMotionActivityManager
        self.activityManager = CMMotionActivityManager()
        
        // start updating activity data and publishing to applications main thread
        self.activityManager.startActivityUpdates(to: .main) { (activity: CMMotionActivity?) in
            guard let activity = activity else { return }
            print(activity)
//            if activity.automotive {
//                if self.routeManager.trackingState == .inactive {
//                    print("INACTIVE")
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 120) {
//                        if activity.automotive {
//                            self.notificationManager.promptToStart()
//                        }
//                    }
//                }
//            } else {
//                if self.routeManager.trackingState == .active {
//                    print("ACTIVE")
//                    // wait 2 minutes, then check again
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 120) {
//                        if !activity.automotive {
//                            self.notificationManager.promptToEnd()
//                        }
//                    }
//                }
//            }
        }
        
    }
    
    func stopMotionUpdates() {
        self.activityManager.stopActivityUpdates()
    }
}


