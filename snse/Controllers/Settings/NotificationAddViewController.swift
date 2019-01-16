//
//  NotificationAddViewController.swift
//  snse
//
//  Created by Blake Barrett on 1/15/19.
//  Copyright © 2019 Blake Barrett. All rights reserved.
//

import UIKit
import EventKit

protocol AddNotificationViewDelegate: class {
    func add(_ date: Date)
}

class NotificationAddViewController: UIViewController {
    public static let identifier = "NotificationAddViewController"
    
    @IBOutlet weak var pickerView: UIDatePicker!
    @IBOutlet weak var saveButtonView: UIBarButtonItem!
    
    weak var delegate: AddNotificationViewDelegate?
    
    override func viewDidLoad() {
        let selector = #selector(self.onDatePickerValueChanged(_:))
        pickerView.addTarget(self, action: selector, for: .valueChanged)
    }
    
    @IBAction func onCancelPressed(_ sender: UIBarButtonItem) {
        close()
    }
    
    @IBAction func onSavePressed(_ sender: UIBarButtonItem) {
        save()
        close()
    }
    
    @objc func onDatePickerValueChanged(_ sender: UIDatePicker) {
        saveButtonView.isEnabled = true
    }
    
    func save() {
        let when = pickerView.date
        delegate?.add(when)
    }
}
