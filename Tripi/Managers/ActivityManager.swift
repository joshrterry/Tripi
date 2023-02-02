//
//  ActivityManager.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-11-17.
//

// http://www.wepstech.com/coremotion-in-ios-swift-5/

import Foundation
import CoreMotion
import UserNotifications

class ActivityManager {
    
    var activityManager: CMMotionActivityManager!
    let notificationManager = NotificationManager()
    
    init() {
        // creates a new instance of CMMotionActivityManager
        self.activityManager = CMMotionActivityManager()
        
        // start updating activity data and publishing to applications main thread
        self.activityManager.startActivityUpdates(to: .main) { (activity: CMMotionActivity?) in
            guard let activity = activity else { return }
            DispatchQueue.main.async {
                if activity.automotive {
                    print("Automotive")
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 120) {
                        if !activity.automotive {
                            self.notificationManager.promptToEnd()
                        }
                    }
                }
            }
        }
    }
}


