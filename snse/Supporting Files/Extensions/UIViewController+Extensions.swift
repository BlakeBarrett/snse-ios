//
//  UIViewController+Extensions.swift
//  snse
//
//  Created by Blake Barrett on 1/5/19.
//  Copyright © 2019 Blake Barrett. All rights reserved.
//

import UIKit
import LocalAuthentication

// Tip-of-the-hat to:
// https://medium.com/@johnsundell/using-child-view-controllers-as-plugins-in-swift-458e6b277b54
extension UIViewController {
    
    func add(_ child: UIViewController, to view: UIView?) {
        addChild(child)
        let target = view ?? self.view
        target?.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}

extension UIViewController {
    
    static func getViewController(with identifier: String, from storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> UIViewController? {
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
    
    static func show(viewWithId id: String, in navigationController: UINavigationController? = nil) -> UIViewController? {
        guard let controller = getViewController(with: id) else { return nil }
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.pushViewController(controller, animated: true)
        return controller
    }
    
    func show(viewControllerWithId id: String, modally: Bool = true, animated: Bool = true) -> UIViewController? {
        if let controller = UIViewController.getViewController(with: id) {
            self.show(controller, modally: modally, animated: animated)
            return controller
        }
        return nil
    }
    
    func show(_ viewController: UIViewController, modally: Bool = true, animated: Bool = true) {
        viewController.providesPresentationContextTransitionStyle = modally
        viewController.definesPresentationContext = modally
        viewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        
        present(viewController, animated: animated)
    }
    
    func setStatusBar(hidden: Bool) {
        modalPresentationCapturesStatusBarAppearance = !hidden
        UIApplication.shared.isStatusBarHidden = hidden
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func showNavBar(animated: Bool = false) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func hideNavBar(animated: Bool = false) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func setLargeTitleMode(_ value: Bool) {
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = value
            navigationItem.largeTitleDisplayMode = UINavigationItem.LargeTitleDisplayMode.automatic
        }
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
            case Locale.init(identifier: "de").languageCode:
                reason = "Nur der Besitzer des Geräts hat Zugriff."
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

extension UIViewController {
    
    @objc func getPresentationDuration() -> TimeInterval {
        return 0.0
    }
    
    func close() {
        dismiss(animated: true)
        navigationController?.dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    func startCountdown() {
        let duration = getPresentationDuration()
        if duration > 0 {
            Timer.scheduledTimer(withTimeInterval: duration,
                                 repeats: false) { [weak self] (timer) in
                                    timer.invalidate()
                                    self?.close()
            }
        }
    }
}
