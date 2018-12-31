//
//  UILabel+Extensions.swift
//  snse
//
//  Created by Blake Barrett on 12/30/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import UIKit

extension UILabel {
    func updateFontSize(_ value: CGFloat) {
        self.font = self.font.withSize(value)
        self.sizeToFit()
    }
}
