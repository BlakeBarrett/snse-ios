//
//  UITextView+Extensions.swift
//  snse
//
//  Created by Blake Barrett on 4/26/19.
//  Copyright © 2019 Blake Barrett. All rights reserved.
//

import UIKit

extension UITextView {
    
    func hasScrollContent() -> Bool {
        return self.contentSize.height > self.bounds.height
    }
}
