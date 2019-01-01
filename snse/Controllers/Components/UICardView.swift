//
//  CardView.swift
//  snse
//
//  Created by Blake Barrett on 12/23/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import UIKit

class UICardView: UIView {
    
    override func draw(_ rect: CGRect) {
        layer.masksToBounds = true
        layer.cornerRadius = 10
        super.draw(rect)
    }
}
