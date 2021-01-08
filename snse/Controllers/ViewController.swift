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

    static let identifier = "mainEntryViewController"
    
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
        decorate(label: label)
        addTapListener(to: label)
        navigationItem.titleView = label
    }
    
    func decorate(label: UILabel,
                  with font: UIFont? = Fonts.signPainter36 ) {
        label.font = font
        label.text = navigationItem.title
        label.sizeToFit()
        label.textColor = UIColor.darkText
    }
    
    func addTapListener(to label: UILabel,
                        for selector: Selector = #selector(onSnseLabelTap)) {
        let tap = UITapGestureRecognizer(target: self, action: selector)
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
    }
    
    @objc func onSnseLabelTap() {
        
        // Catalyst opens in Safari
        #if targetEnvironment(macCatalyst)
        
        if let url = URL(string: "https://github.com/BlakeBarrett/snse-ios/blob/main/ABOUT.md") {
            UIApplication.shared.open(url)
            return
        }
        
        // iOS opens in custom view
        #else
        
        let aboutVC = AboutViewController()
        aboutVC.view.frame = self.view.bounds
        UIViewController.show(aboutVC,
                              in: navigationController)
        
        #endif
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
        activity.isEligibleForPrediction = true
        activity.persistentIdentifier = NSUserActivityPersistentIdentifier(stringLiteral: identifier)
        
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
