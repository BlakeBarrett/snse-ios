//
//  ViewController.swift
//  snse
//
//  Created by Blake Barrett on 11/8/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import UIKit
import StoreKit

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
        
        appWasLaunched()
        
        addQuestionaireChildViewController()
        
        addSettingsButton()
        
        decorateTitle()
        
        setupIntents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Don't show the nav bar for the main view.
        hideNavBar()
    }
    
    @IBAction func onSaveButtonPressed(_ sender: Any) {
        questionaireView.save()
        
        if let thankVC = ViewController.getViewController(with: ThankViewController.identifier) as? ThankViewController {
            thankVC.onDismiss = { [weak self] in
                self?.promptForRating()
            }
            show(thankVC, modally: true, animated: true)
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
    
    func addQuestionaireChildViewController() {
        questionaireView.view.frame = entryView.frame
        add(questionaireView, to: entryView)
        questionaireView.reset()
    }
    
    func addSettingsButton() {
        let button = UIBarButtonItem(image: UIImage(named: "bell"),
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

extension ViewController {
    
    func setupIntents() {
        let identifier = "com.blakebarrett.snse.feeling"
        
        let activity = NSUserActivity(activityType: identifier) // 1
        activity.title = "Feeling Great?" // 2
        activity.userInfo = ["feeling" : "😊"] // 3
        activity.isEligibleForSearch = true // 4
        if #available(iOS 12.0, *) {
            activity.isEligibleForPrediction = true // 5
            activity.persistentIdentifier = NSUserActivityPersistentIdentifier(stringLiteral: identifier) // 6
        }
        view.userActivity = activity // 7
        activity.becomeCurrent() // 8
    }
}

extension ViewController {
    
    private struct StoreKitKeys {
        static let launches = "Number of times the app has launched."
    }
    
    func appWasLaunched() {
        let defaults = UserDefaults.standard
        let launches = howManyTimesHasAppBeenLaunched()
        defaults.set(launches + 1, forKey: StoreKitKeys.launches)
    }
    
    func howManyTimesHasAppBeenLaunched() -> Int {
        let defaults = UserDefaults.standard
        return defaults.value(forKey: StoreKitKeys.launches) as? Int ?? 0
    }
    
    func promptForRating() {
        if howManyTimesHasAppBeenLaunched() % 5 != 0 {
            return
        }
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
}
