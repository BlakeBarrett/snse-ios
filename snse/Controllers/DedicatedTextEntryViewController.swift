//
//  DedicatedTextEntryViewController.swift
//  snse
//
//  Created by Blake Barrett on 12/31/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import UIKit

protocol TextEntryDelegate: class {
    
    func updateText(with value: String?)
}

class DedicatedTextEntryViewController: UIViewController {
    
    public static let identifier = "dedicatedTextEntryViewController"
    
    @IBOutlet weak var mainTextView: UITextView!
    @IBOutlet weak var keyboardSpaceSaverView: UIView!
    @IBOutlet weak var toolbarView: UIToolbar!
    
    weak var delegate: TextEntryDelegate?
    var keyboardShowObserver: NSObjectProtocol?
    
    private var keyboardHeight = 0
    private var text: String?
    
    static func show(in navigationController: UINavigationController? = nil) -> DedicatedTextEntryViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: DedicatedTextEntryViewController.identifier) as? DedicatedTextEntryViewController else { return nil }
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.pushViewController(controller, animated: true)
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTextView.becomeFirstResponder()
        mainTextView.text = text
        addKeyboardEventListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanup()
    }
    
    @IBAction func onCancelClicked(_ sender: UIBarButtonItem) {
        if let _ = navigationController {
            navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func onDoneClicked(_ sender: UIBarButtonItem) {
        self.delegate?.updateText(with: self.mainTextView.text)
        if let _ = navigationController {
            navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    public func prepopulateText(with value: String?) {
        text = value
    }
    
    private func cleanup() {
        removeKeyboardEventListener()
        delegate = nil
        keyboardShowObserver = nil
    }
}

extension DedicatedTextEntryViewController {
    
    func addKeyboardEventListener() {
        let center = NotificationCenter.default
        keyboardShowObserver = center.addObserver(forName: UIViewController.keyboardDidShowNotification,
                                                  object: nil,
                                                  queue: nil,
                                                  using: self.onKeyboardShown)
    }
    
    func removeKeyboardEventListener() {
        guard let _ = keyboardShowObserver else { return }
        let center = NotificationCenter.default
        center.removeObserver(keyboardShowObserver!)
    }
    
    func onKeyboardShown(notification: Notification) -> Void {
        
        let info = notification.userInfo ?? [:]
        let infoKeyboardInfoKey = info[UIResponder.keyboardFrameEndUserInfoKey]
        let keyboardRect = (infoKeyboardInfoKey as! NSValue).cgRectValue
        keyboardSpaceSaverView.frame = keyboardRect
        
        let keyboardHeight = keyboardRect.size.height
        print(keyboardHeight)
        
        if (self.keyboardHeight < Int(keyboardHeight)) {
            mainTextView.frame.size.height -= keyboardHeight
            toolbarView.frame.origin.y -= keyboardHeight
            
            // This hack exists because the SwiftKey keyboard decided to throw THREE
            // events for every one keyboardDidShow.
            self.keyboardHeight = Int(keyboardHeight)
        }
    }
}
