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
    
    public let minFontSize = 14.0
    public let maxFontSize = 72.0
    
    @IBOutlet weak var contentView: UICardView!
    
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
        
        waterImageView.image = waterImageFor(value: sentiment)
        waterImageView.tintColor = dateLabel.textColor
        
        decorateFeelingLabel(view: feelingLabel, sentiment: sentiment)
        
        elaborateTextView.text = sentiment?.elaborate
        elaborateTextView.sizeToFit()
        
        let color = sentiment?.color
        feelingLabel.backgroundColor = color
        view.backgroundColor = color
    }
    
    func decorateFeelingLabel(view: UILabel, sentiment: Sentiment?) {
        view.text = sentiment?.feeling
        let intensity = Double(sentiment?.intensity ?? 0) * 0.01
        let size = minFontSize + (intensity * maxFontSize)
        view.font = view.font.withSize(CGFloat(size))
        view.sizeToFit()
    }
    
    func waterImageFor(value: Sentiment?) -> UIImage? {
        let waterImage = (value?.water ?? false) ? "water" : "water-off"
        return UIImage(named: waterImage)
    }
}
