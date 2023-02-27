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
    var activityManager: CMMotionActivityManager!
    let notificationManager = NotificationManager()
    @AppStorage("selectedAutonomy") var selectedAutonomy = 0
    
    func startMotionUpdates(){
        var sentNotification = false
        // creates a new instance of CMMotionActivityManager
        self.activityManager = CMMotionActivityManager()
        
        // start updating activity data and publishing to applications main thread
        self.activityManager.startActivityUpdates(to: .main) { (activity: CMMotionActivity?) in
            guard let activity = activity else { return }
            print(activity)
            if !activity.automotive {
                // wait 2 minutes, then check again
                DispatchQueue.main.asyncAfter(deadline: .now() + 120) {
                    if !activity.automotive {
                        if !sentNotification { // verify that a notification has not already been pushed to the user
                            sentNotification = true
                            if self.selectedAutonomy == 1 {
                                self.notificationManager.promptToEnd()
                            }
                            else if self.selectedAutonomy == 2 {
                                self.notificationManager.autoStopMessage()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func stopMotionUpdates() {
        self.activityManager.stopActivityUpdates()
    }
}


