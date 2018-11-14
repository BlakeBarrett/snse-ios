//
//  QuestionaireView.swift
//  snse
//
//  Created by Blake Barrett on 11/8/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import Foundation
import UIKit

class QuestionaireView: UIView {
    
    private var sentiment = Sentiment()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var sliderControl: UISlider!
    @IBOutlet weak var buttonControl: UIButton!
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var textView: UITextView!
    
    @IBAction func onSegmentedControlValueChanged(_ sender: UISegmentedControl, forEvent event: UIEvent) {
        
        var value = ""
        
        switch sender.selectedSegmentIndex {
        case 0:
            value = "😞"
            break
        case 1:
            value = "😐"
            break
        case 2:
            value = "😊"
            break
        default: break
        }
        
        sentiment.feeling = value
    }
    
    @IBAction func onSliderValueChanged(_ sender: UISlider, forEvent event: UIEvent) {
        sentiment.intensity = Int(sender.value)
    }
    
    @IBAction func onColorButtonClicked(_ sender: UIButton) {
        // TODO: Launch color picker
    }
    
    @IBAction func onSwitchValueChanged(_ sender: UISwitch, forEvent event: UIEvent) {
        sentiment.water = sender.isOn
    }
}

extension QuestionaireView {
    
    func viewDidAppear() {
        self.textView.delegate = self
    }
    
    func reset() {
        self.sentiment = Sentiment()
        self.segmentedControl.selectedSegmentIndex = 1
        self.sliderControl.value = 50
        self.switchControl.isOn = false
        self.switchControl.setOn(false, animated: false)
        self.textView.text = ""
    }
    
    func getSentiment() -> Sentiment {
        sentiment.elaborate = textView.text
        return sentiment
    }
}

extension QuestionaireView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
