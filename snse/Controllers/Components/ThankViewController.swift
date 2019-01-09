//
//  ThankViewController.swift
//  snse
//
//  Created by Blake Barrett on 1/8/19.
//  Copyright © 2019 Blake Barrett. All rights reserved.
//

import UIKit

class ThankViewController: UIViewController {
    
    static let identifier = "thankViewController"
    
    var presentationDuration = 3.0
    
    override func viewDidLoad() {
        startCountdown()
    }
    
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        close()
    }
}

extension ThankViewController {
    
    func close() {
        dismiss(animated: true)
        navigationController?.dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: presentationDuration,
                             repeats: false) { [weak self] (timer) in
                                timer.invalidate()
                                self?.close()
        }
    }
}
