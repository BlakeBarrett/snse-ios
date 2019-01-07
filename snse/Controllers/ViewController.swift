//
//  ViewController.swift
//  snse
//
//  Created by Blake Barrett on 11/8/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var questionaireView = EntryFormCardViewController()
    var authenticated = false
    
    @IBOutlet weak var entryView: UIView!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        navigationItem.rightBarButtonItem = nil
        questionaireView.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionaireView.view.frame = entryView.frame
        add(questionaireView, to: entryView)
        questionaireView.reset()
        
        addSettingsButton()
        decorateTitle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Don't show the nav bar for the main view.
        hideNavBar()
    }
    
    @IBAction func onSaveButtonPressed(_ sender: Any) {
        if let sentiment = questionaireView.sentiment() {
            SentimentFactory.save(sentiment)
            questionaireView.reset()
        }
    }
    
    @IBAction func onHistoryButtonPressed(_ sender: Any) {
        if !authenticated {
            authenticateUser() {
                self.authenticated = true
                self.showHistory()
            }
            return
        }
        showHistory()
    }
    
    func showHistory() {
        let _ = UIViewController.show(viewWithId: SentimentViewController.identifier,
                                      in: navigationController)
    }
    
    func decorateTitle() {
        let label = UILabel(frame: CGRect.zero)
        let font = UIFont(name: "SignPainter-HouseScript", size: 36.0)
        label.font = font
        label.text = navigationItem.title
        label.sizeToFit()
        navigationItem.titleView = label
    }
    
    func addSettingsButton() {
        let button = UIBarButtonItem(image: UIImage(named: "settings"),
                                     style: UIBarButtonItem.Style.plain,
                                     target: self,
                                     action: #selector(onSettingsButtonPressed(_:)))
        button.tintColor = UIColor.darkGray
        navigationItem.rightBarButtonItem = button
    }
    
    @objc func onSettingsButtonPressed(_ sender: Any) {
        let _ = NotificationSettingsTableView.show(viewWithId: NotificationSettingsTableView.identifier,
                                                   in: self.navigationController)
    }
}
