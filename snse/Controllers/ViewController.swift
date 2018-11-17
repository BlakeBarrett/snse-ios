//
//  ViewController.swift
//  snse
//
//  Created by Blake Barrett on 11/8/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    @IBOutlet weak var questionaireView: QuestionaireView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var authenticated = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionaireView.reset()
        questionaireView.navigationController = navigationController
        addKeyboardEventListeners()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Don't show the nav bar for the main view.
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func onSaveButtonPressed(_ sender: Any) {
        let sentiment = questionaireView.getSentiment()
        SentimentFactory.save(sentiment)
        questionaireView.reset()
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: HistoricalSentimentViewController.identifier)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.pushViewController(controller, animated: true)
    }
}

// Keyboard show/hide
extension ViewController {
    
    func addKeyboardEventListeners() {
        let center = NotificationCenter.default
        center.addObserver(forName: UIViewController.keyboardDidShowNotification, object: nil, queue: nil, using: self.onKeyboardShown)
        center.addObserver(forName: UIViewController.keyboardWillHideNotification, object: nil, queue: nil, using: self.onKeyboardHidden)
    }
    
    func onKeyboardShown(notification: Notification) -> Void {
        let info = notification.userInfo ?? [:]
        let infoKeyboardInfoKey = info[UIResponder.keyboardFrameEndUserInfoKey]
        let keyboardSize = (infoKeyboardInfoKey as! NSValue).cgRectValue.size
        
        let originalContentInset = scrollView.contentInset
        let contentInsets = UIEdgeInsets.init(top: originalContentInset.top, left: originalContentInset.left, bottom: keyboardSize.height, right: originalContentInset.right)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        let newY = UIDevice.current.userInterfaceIdiom == .pad ? keyboardSize.height : scrollView.contentOffset.y
        let point =  CGPoint(x: 0.0, y: newY)
        scrollView.setContentOffset(point, animated: true)
    }
    
    func onKeyboardHidden(notification: Notification) -> Void {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}

// for LocalAuthentication code.
extension ViewController {
    
    func authenticateUser(_ success: (() -> Void)?) {
        let context = LAContext()
        var error: NSError?
        
        let hasBiometrics = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        let hasPasscode = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        if hasBiometrics || hasPasscode {
            var reason = "Only the device' owner has access."
            switch Locale.current.languageCode {
            case Locale.init(identifier: "es").languageCode:
                reason = "Solo el propietario del dispositivo tiene acceso."
                break
            case Locale.init(identifier: "en").languageCode:
                reason = "Only the device' owner has access."
                break
            case Locale.init(identifier: "ru").languageCode:
                reason = "Доступ имеет только владелец устройства."
                break
            default: break
            }
            
            let onAuthComplete: (Bool, Error?) -> Void = { authenticated, _ in
                DispatchQueue.main.async {
                    if authenticated {
                        success?()
                    }
                }
            }
            
            let policy = hasBiometrics ? LAPolicy.deviceOwnerAuthenticationWithBiometrics : LAPolicy.deviceOwnerAuthentication
            context.evaluatePolicy(policy, localizedReason: reason, reply: onAuthComplete)
        }
    }
}
