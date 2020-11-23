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
        if #available(iOS 11.0, tvOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
}
