//
//  ThankViewController.swift
//  snse
//
//  Created by Blake Barrett on 1/8/19.
//  Copyright © 2019 Blake Barrett. All rights reserved.
//

import UIKit

// TODO: Turn this into a subclass of UIViewController that presents-modally and auto-dismisses on touch and optionally after a timeout.
// -- BlakeB 20190110

class ThankViewController: UIViewController {
    
    static let identifier = "thankViewController"
    
    override func viewDidLoad() {
        super.startCountdown()
    }
    
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        super.close()
    }
    
    override func getPresentationDuration() -> TimeInterval {
        return 3.0
    }
}
