//
//  DetailCardViewController.swift
//  snse
//
//  Created by Blake Barrett on 12/21/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import Foundation
import UIKit

class DetailCardViewController: UIViewController {
    
    public static let nibName = "DetailCardView"
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var waterImageView: UIImageView!
    @IBOutlet weak var feelingLabel: UILabel!
    @IBOutlet weak var elaborateTextView: UITextView!
    
    var sentiment: Sentiment?
    
    override func awakeFromNib() {
        viewDidLoad()
    }
    
    override func viewDidLoad() {
        dateLabel.text = sentiment?.getDateString()
        
        let waterImage = (sentiment?.water ?? false) ? "water" : "water-off"
        waterImageView.image = UIImage(named: waterImage)
        waterImageView.tintColor = dateLabel.textColor
        
        feelingLabel.text = sentiment?.feeling
        let intensity = Double(sentiment?.intensity ?? 0) * 0.01
        let size = max(10, intensity * 72)
        feelingLabel.font = feelingLabel.font.withSize(CGFloat(size))
        feelingLabel.sizeToFit()
        
        elaborateTextView.text = sentiment?.elaborate
        elaborateTextView.sizeToFit()
        
        let color = sentiment?.color
        feelingLabel.backgroundColor = color
        view.backgroundColor = color
        
        roundCornersOf(view: contentView)
        applyShadowTo(view: contentView)
    }
    
    func roundCornersOf(view: UIView, radius: CGFloat = 10) {
        view.layer.masksToBounds = true
        view.layer.cornerRadius = radius
    }
    
    func applyShadowTo(view: UIView) {
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = view.layer.cornerRadius
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
    }
}
