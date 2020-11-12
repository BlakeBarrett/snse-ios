//
//  FeelingEntryView.swift
//  snse
//
//  Created by Blake Barrett on 12/30/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import UIKit

@IBDesignable class FeelingEntryView: UIView {
    
    private var minFontSize: CGFloat = 14.0
    private var maxFontSize: CGFloat = 72.0
    private var fontSize = 72
    private var selectedButton: UIButton?
    
    var intensity: Int = 72 {
        didSet {
            fontSize = intensity
            updateLabelSizes()
        }
    }
    
    var deselectedColor: UIColor? = UIColor.clear
    var selectedColor: UIColor? = UIColor.lightGray {
        didSet {
            updateBackgroundColors()
        }
    }
    var selectedIndex = -1 {
        didSet {
            updateBackgroundColors()
        }
    }
    var selectedFeeling: String? {
        get {
            return self.selectedButton?.titleLabel?.text
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func draw(_ rect: CGRect) {
        removeAll()
        let buttonLabels = Sentiment.Feels.all
        var count = 0
        buttonLabels.forEach({ value in
            let height = self.bounds.height
            let width = self.bounds.width / CGFloat(buttonLabels.count)
            let x = CGFloat(CGFloat(count) * width)
            let y = CGFloat(0)
            
            let button = generateButton(with: value)
            button.frame = CGRect(x: x, y: y, width: width, height: height)
            button.tag = count
            addSubview(button)
            count += 1
        })
        updateBackgroundColors()
    }
    
    func generateButton(with title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: UIControl.State.normal)
        button.titleLabel?.textAlignment = NSTextAlignment.center
        button.titleLabel?.updateFontSize(CGFloat(fontSize))
        button.addTarget(self, action: #selector(self.onClick(_:)), for: .touchUpInside)
        return button
    }
    
    @objc func onClick(_ view: Any?) -> Void {
        guard let view = view as? UIButton else {
            return
        }
        self.selectedIndex = view.tag
        self.selectedButton = view
        self.updateBackgroundColors()
    }
    
    func updateBackgroundColors() {
        subviews.forEach({ view in
            view.backgroundColor = (view.tag == self.selectedIndex ? selectedColor : deselectedColor)
        })
        backgroundColor = UIColor.white
    }
    
    func updateLabelSizes() {
        subviews.forEach({ view in
            guard let view = view as? UIButton else {
                return
            }
            let intensePercent = CGFloat(intensity) * 0.01
            let size = CGFloat(minFontSize + (intensePercent * maxFontSize))
            view.titleLabel?.updateFontSize(size)
        })
    }
    
    func removeAll() {
        subviews.forEach({ view in
            view.removeFromSuperview()
        })
    }
    
    func reset() {
        self.selectedButton = nil
        selectedColor = deselectedColor
        selectedIndex = -1
        setNeedsDisplay()
    }
}
