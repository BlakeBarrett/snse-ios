//
//  NotificationAlarmTableViewCell.swift
//  snse
//
//  Created by Blake Barrett on 1/16/19.
//  Copyright © 2019 Blake Barrett. All rights reserved.
//

import UIKit

class NotificationAlarmTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "notificationCellReuseIdentifier"
    static let nibIdentifier = "NotificationAlarmTableViewCell"
    
    @IBOutlet weak var timeLabel: UILabel!
    
    func prettyString(for value: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return dateFormatter.string(from: value)
    }
    
    func set(_ value: Date?) {
        guard let value = value else { return }
        timeLabel.text = prettyString(for: value)
    }
}
