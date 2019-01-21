//
//  DetailCardViewController.swift
//  snse
//
//  Created by Blake Barrett on 12/21/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import UIKit

@IBDesignable
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let when = sentiment?.getLongDateString()
        dateLabel.text = when
        navigationController?.title = when
        self.title = when
        
        waterImageView.image = waterImageFor(value: sentiment)
        waterImageView.tintColor = dateLabel.textColor
        
        decorateFeelingLabel(view: feelingLabel, sentiment: sentiment)
        
        elaborateTextView.text = sentiment?.elaborate
        elaborateTextView.sizeToFit()
        
        setBackgroundColors(color(sentiment))
        
        setStatusBar(hidden: true)
        
        addTapListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setStatusBar(hidden: false)
        sentiment = nil
    }
}

extension DetailCardViewController {

    func setBackgroundColors(_ color: UIColor) {
        feelingLabel.backgroundColor = color
        view.backgroundColor = color.adjust(brightnessBy: -0.1)
    }
    
    func color(_ sentiment: Sentiment?) -> UIColor {
        return sentiment?.color ?? UIColor.groupTableViewBackground
    }
    
    func decorateFeelingLabel(view: UILabel, sentiment: Sentiment?) {
        view.text = sentiment?.feeling
        let intensity = Double(sentiment?.intensity ?? 0) * 0.01
        let size = CGFloat(minFontSize + (intensity * maxFontSize))
        view.updateFontSize(size)
    }
    
    func waterImageFor(value: Sentiment?) -> UIImage? {
        let waterImage = (value?.water ?? false) ? "water" : "water-off"
        return UIImage(named: waterImage)
    }
}

extension DetailCardViewController {
    
    func addTapListener() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        // Don't worry, self.elaborateTextView captures its own gesture events.
        self.view.addGestureRecognizer(recognizer)
    }
    
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        super.close()
    }
}

extension UITextView {
    
    func hasScrollContent() -> Bool {
        return self.contentSize.height > self.bounds.height
    }
}
