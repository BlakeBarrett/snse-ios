//
//  NotificationSettingsTableView.swift
//  snse
//
//  Created by Blake Barrett on 1/6/19.
//  Copyright © 2019 Blake Barrett. All rights reserved.
//

import UIKit

@IBDesignable
class NotificationSettingsTableView: UITableViewController {
    
    public static let identifier = "NotificationSettingsTableView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addAddButtonToRightNavigationItem()
    }
    
    deinit {
        navigationItem.rightBarButtonItem = nil
    }
    
    func addAddButtonToRightNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(onAddClicked(_:)))
    }
    
    @objc func onAddClicked(_ sender: UIBarButtonItem) {
        
    }
    
}
