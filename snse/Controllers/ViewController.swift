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
    
    var authenticated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionaireView.reset()
        questionaireView.navigationController = navigationController
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

// for LocalAuthentication code.
extension ViewController {
    
    func authenticateUser(_ success: (() -> Void)?) {
        let context = LAContext()
        var error: NSError?
        
        let hasBiometrics = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        let hasPasscode = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        if hasBiometrics || hasPasscode {
            let reason = "Only the device' owner has access."
            
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
