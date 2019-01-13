//
//  UIDevice+Extensions.swift
//  snse
//
//  Created by Blake Barrett on 1/12/19.
//  Copyright © 2019 Blake Barrett. All rights reserved.
//

import UIKit

// Thanks!: https://medium.com/@cafielo/how-to-detect-notch-screen-in-swift-56271827625d
extension UIDevice {
    var hasNotch: Bool {
        if #available(iOS 11.0, *) {
            let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            return bottom > 0
        } else {
            // Fallback on earlier versions
            return false
        }
    }
}
