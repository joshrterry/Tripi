//
//  NotificationManager.swift
//  Tripi
//
//  Created by Joshua Terry on 2023-01-28.
//

import Foundation
import UserNotifications

class NotificationManager {

    // https://www.hackingwithswift.com/books/ios-swiftui/scheduling-local-notifications

    func promptToEnd() {
            // define content of the push notification
            let content = UNMutableNotificationContent()
            content.title = "Still driving?"
            content.body = "It looks like you've stopped. Press here to pause or end trip tracking."
            content.sound = UNNotificationSound.default

            // assigned random identifier and content to request
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)

            // add notification request to queue
            UNUserNotificationCenter.current().add(request)
    }

}


