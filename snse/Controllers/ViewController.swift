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
        center.addObserver(forName: UIViewController.keyboardDidChangeFrameNotification, object: nil, queue: nil, using: self.onKeyboardChangeFrameNotification)
        center.addObserver(forName: UIViewController.keyboardDidShowNotification, object: nil, queue: nil, using: self.onKeyboardShownNotification)
        center.addObserver(forName: UIViewController.keyboardWillHideNotification, object: nil, queue: nil, using: self.onKeyboardHiddenNotification)
    }
    
    func onKeyboardChangeFrameNotification(notification: Notification) -> Void {
        let userInfo = notification.userInfo ?? [:]
        print(userInfo)
        
    }
    
    func onKeyboardShownNotification(notification: Notification) -> Void {
//        let show = notification.name == UIViewController.keyboardDidShowNotification
//        let userInfo = notification.userInfo ?? [:]
//        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        let adjustmentHeight = keyboardFrame.height * (show ? 1 : -1)
//        let originalContentOffset = scrollView.contentOffset
//        let newContentOffset = CGPoint(x: originalContentOffset.x, y: originalContentOffset.y + adjustmentHeight)
//        scrollView.contentOffset = newContentOffset
        
        /*
        
         // one
         
         AnyHashable("UIKeyboardAnimationDurationUserInfoKey"): 0.25,
         AnyHashable("UIKeyboardBoundsUserInfoKey"): NSRect: {{0, 0}, {1024, 0}},
         AnyHashable("UIKeyboardAnimationCurveUserInfoKey"): 7,
         AnyHashable("UIKeyboardCenterEndUserInfoKey"): NSPoint: {512, 768},
         AnyHashable("UIKeyboardIsLocalUserInfoKey"): 1,
         AnyHashable("UIKeyboardFrameBeginUserInfoKey"): NSRect: {{0, 768}, {1024, 0}},
         AnyHashable("UIKeyboardFrameEndUserInfoKey"): NSRect: {{0, 768}, {1024, 0}},
         AnyHashable("UIKeyboardCenterBeginUserInfoKey"): NSPoint: {512, 768}]
         
         // two
         
         AnyHashable("UIKeyboardAnimationDurationUserInfoKey"): 0,
         AnyHashable("UIKeyboardBoundsUserInfoKey"): NSRect: {{0, 0}, {1024, 398}},
         AnyHashable("UIKeyboardAnimationCurveUserInfoKey"): 7,
         AnyHashable("UIKeyboardCenterEndUserInfoKey"): NSPoint: {512, 569},
         AnyHashable("UIKeyboardIsLocalUserInfoKey"): 1,
         AnyHashable("UIKeyboardFrameBeginUserInfoKey"): NSRect: {{0, 768}, {1024, 0}},
         AnyHashable("UIKeyboardFrameEndUserInfoKey"): NSRect: {{0, 370}, {1024, 398}},
         AnyHashable("UIKeyboardCenterBeginUserInfoKey"): NSPoint: {512, 768}]
        
        */


        let info = notification.userInfo ?? [:]
        let infoKeyboardInfoKey = info[UIResponder.keyboardFrameEndUserInfoKey]
        let keyboardSize = (infoKeyboardInfoKey as! NSValue).cgRectValue.size
        var backgroundRect = questionaireView.frame
        backgroundRect.size.height += keyboardSize.height
        questionaireView.frame = backgroundRect
        let newY = questionaireView.frame.size.height + keyboardSize.height
        let point =  CGPoint(x: 0.0, y: newY)
        scrollView.setContentOffset(point, animated: true)
        
//        NSDictionary* info = [aNotification userInfo];
//        CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
//        CGRect bkgndRect = activeField.superview.frame;
//        bkgndRect.size.height += kbSize.height;
//        [activeField.superview setFrame:bkgndRect];
//        [scrollView setContentOffset:CGPointMake(0.0, activeField.frame.origin.y-kbSize.height) animated:YES];
        

//        let info = notification.userInfo ?? [:]
//        let infoKeyboardInfoKey = info[UIResponder.keyboardFrameEndUserInfoKey]
//        let keyboardSize = (infoKeyboardInfoKey as! NSValue).cgRectValue.size
//        let contentInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
//        scrollView.contentInset = contentInsets;
//        scrollView.scrollIndicatorInsets = contentInsets;
    }
    
    func onKeyboardHiddenNotification(notification: Notification) -> Void {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = contentInsets;
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
