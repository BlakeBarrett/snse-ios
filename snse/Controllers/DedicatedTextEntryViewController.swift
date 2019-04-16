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
    
    func saveWasCalled(with value: String?)
}

@IBDesignable
class DedicatedTextEntryViewController: UIViewController {
    
    public static let identifier = "dedicatedTextEntryViewController"
    
    @IBOutlet weak var mainTextView: UITextView!
    @IBOutlet weak var keyboardSpaceSaverView: UIView!
    @IBOutlet weak var keyboardHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: TextEntryDelegate?
    var keyboardShowObserver: NSObjectProtocol?
    
    private var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTextView.becomeFirstResponder()
        mainTextView.text = text
        setupNavButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addKeyboardEventListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanup()
    }
    
    private func setupNavButtons() {
        // Done, here means "I'm done here, take me back."
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(onDoneClicked(_:)))
        navigationItem.leftBarButtonItem?.style = UIBarButtonItem.Style.plain
        
        // Save is where the big-money's at; it's Done++
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                           target: self,
                                                           action: #selector(onSaveClicked(_:)))
        navigationItem.rightBarButtonItem?.style = UIBarButtonItem.Style.done
    }
    
    @objc func onDoneClicked(_ sender: UIBarButtonItem) {
        self.delegate?.updateText(with: self.mainTextView.text)
        if let _ = navigationController {
            navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }

    @objc func onSaveClicked(_ sender: UIBarButtonItem) {
        self.delegate?.saveWasCalled(with: self.mainTextView.text)
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
        keyboardHeightConstraint.constant = keyboardHeight
        mainTextView.frame.size.height -= keyboardHeight
        view.layoutIfNeeded()
    }
}
