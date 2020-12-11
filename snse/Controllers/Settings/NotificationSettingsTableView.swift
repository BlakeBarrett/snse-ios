//
//  NotificationSettingsTableView.swift
//  snse
//
//  Created by Blake Barrett on 1/6/19.
//  Copyright © 2019 Blake Barrett. All rights reserved.
//

import UIKit
import UserNotifications

@IBDesignable
class NotificationSettingsTableView: UITableViewController {
    
    public static let identifier = "NotificationSettingsTableView"
    
    struct Constants {
        static let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                      target: self,
                                                      action: #selector(onAddClicked(_:)))
        
        static let selectBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Select", comment: "Select"),
                                                         style: .plain,
                                                         target: self,
                                                         action: #selector(handleSelectButton))
        
        static let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                         target: self,
                                                         action: #selector(handleSelectButton))
        
    }
    
    private lazy var notificationUtils = NotificationUtils()
    var dates: [Date]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableViewCell(tableView: tableView)
        addButtonToRightNavigationItems(navigationItem: navigationItem)
        reloadData()
    }
    
    deinit {
        navigationItem.rightBarButtonItem = nil
    }
    
    func registerTableViewCell(tableView: UITableView) {
        let cellNib = UINib(nibName: NotificationAlarmTableViewCell.nibIdentifier, bundle: Bundle.main)
        tableView.register(cellNib, forCellReuseIdentifier: NotificationAlarmTableViewCell.reuseIdentifier)
        tableView.estimatedRowHeight = 100
    }
    
    func addButtonToRightNavigationItems(navigationItem: UINavigationItem,
                                         add: UIBarButtonItem = Constants.addBarButtonItem,
                                         select: UIBarButtonItem = Constants.selectBarButtonItem) {
        #if targetEnvironment(macCatalyst)
            navigationItem.rightBarButtonItems = [add, select]
        #else
            navigationItem.rightBarButtonItem = add
        #endif
    }
    
    func reloadData() {
        notificationUtils.center.getPendingNotificationRequests { [unowned self] (requests: [UNNotificationRequest]) in
            self.dates = [Date]()
            requests.forEach() {[unowned self] request in
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    let components = trigger.dateComponents
                    if let date = Calendar.current.date(from: components) {
                        self.dates?.append(date)
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func onAddClicked(_ sender: UIBarButtonItem) {
        notificationUtils.getAuthorization(success: { [unowned self] in
            if let controller = self.show(viewControllerWithId: NotificationAddViewController.identifier,
                                          modally: true,
                                          animated: true) as? NotificationAddViewController {
                controller.delegate = self
            }
        }, failure: { error in
            
        })
    }
}

extension NotificationSettingsTableView: AddNotificationViewDelegate {
    
    func add(_ date: Date) {
        notificationUtils.scheduleNotification(at: date)
        reloadData()
    }
}

extension NotificationSettingsTableView {
    
    func remove(_ value: Date?) {
        guard let value = value else { return }
        notificationUtils.center.getPendingNotificationRequests { [unowned self] (requests: [UNNotificationRequest]) in
            self.dates = [Date]()
            requests.forEach() {[unowned self] request in
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    let components = trigger.dateComponents
                    if let date = Calendar.current.date(from: components) {
                        if date == value {
                            self.notificationUtils.center.removePendingNotificationRequests(withIdentifiers: [request.identifier])
                        }
                    }
                }
            }
            self.reloadData()
        }
    }
}

extension NotificationSettingsTableView {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationAlarmTableViewCell.reuseIdentifier,
                                                 for: indexPath) as! NotificationAlarmTableViewCell
        cell.prepareForReuse()
        
        let row = self.dates?[indexPath.row]
        cell.set(row)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        
        if  editingStyle == .delete {
            let selectedDate = self.dates?[indexPath.row]
            remove(selectedDate)
        }
    }
}

extension NotificationSettingsTableView {
    @objc func handleSelectButton() {
        tableView.isEditing = !tableView.isEditing
        
        if tableView.isEditing {
            navigationItem.rightBarButtonItems = [Constants.addBarButtonItem, Constants.cancelBarButtonItem]
        } else {
            navigationItem.rightBarButtonItems = [Constants.addBarButtonItem, Constants.selectBarButtonItem]
        }
    }
}
