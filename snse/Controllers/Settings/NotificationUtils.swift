//
//  EventUtils.swift
//  snse
//
//  Created by Blake Barrett on 1/15/19.
//  Copyright © 2019 Blake Barrett. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationUtils {
    
    let center = UNUserNotificationCenter.current()
    
    func getAuthorization(success: (()->Void)?, failure: ((Error?)->Void)?) {
        
        let options: UNAuthorizationOptions = [.alert, .badge]
        center.requestAuthorization(options: options) { (granted, error) in
            if granted {
                success?()
            } else {
                failure?(error)
            }
        }
    }
    
    private func createNotification() -> UNNotificationContent {
        let notification = UNMutableNotificationContent()
        notification.title = "Snse"
        notification.body = "How are you feeling?"
        notification.sound = UNNotificationSound.default
        return notification
    }
    
    private func createTrigger(for date: Date) -> UNCalendarNotificationTrigger {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    }
    
    func scheduleNotification(at date: Date, withCompletionHandler: ((Error?)->Void)? = nil) {
        
        let identifier = date.description
        let trigger = createTrigger(for: date)
        let notification = createNotification()
        let request = UNNotificationRequest(identifier: identifier, content: notification, trigger: trigger)
        
        center.add(request, withCompletionHandler: withCompletionHandler)
    }
}
