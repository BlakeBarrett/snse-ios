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
        UIViewController.show(viewWithId: SentimentViewController.identifier,
                              in: navigationController)
    }
    
    func decorateTitle() {
        let label = UILabel(frame: CGRect.zero)
        let font = Fonts.signPainter36
        label.font = font
        label.text = navigationItem.title
        label.sizeToFit()
        label.textColor = UIColor.darkText
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
        NotificationSettingsTableView.show(viewWithId: NotificationSettingsTableView.identifier,
                                           in: self.navigationController)
    }
}

extension ViewController {
    
    func setupIntents() {
        let identifier = "com.blakebarrett.snse.feeling"
        
        let activity = NSUserActivity(activityType: identifier)
        activity.title = NSLocalizedString("Feeling great?", comment: "Feeling Great?")
        activity.userInfo = ["feeling" : "😊"]
        activity.isEligibleForSearch = true
        if #available(iOS 12.0, *) {
            activity.isEligibleForPrediction = true
            activity.persistentIdentifier = NSUserActivityPersistentIdentifier(stringLiteral: identifier)
        }
        view.userActivity = activity
        activity.becomeCurrent()
    }
}

extension UIViewController {
    
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
