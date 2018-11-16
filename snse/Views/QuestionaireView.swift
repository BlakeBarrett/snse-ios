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
    
    // TODO: This really doesn't belong here.
    var navigationController: UINavigationController?
    
    // labels
    @IBOutlet weak var feelingLabel: UILabel!
    @IBOutlet weak var intensityLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var waterLabel: UILabel!
    
    // controls
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var sliderControl: UISlider!
    @IBOutlet weak var buttonControl: UIButton!
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var colorButtonControl: UIButton!
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
        showColorPicker()
    }
    
    @IBAction func onSwitchValueChanged(_ sender: UISwitch, forEvent event: UIEvent) {
        sentiment.water = sender.isOn
    }
}

extension QuestionaireView {
    
    func reset() {
        self.sentiment = Sentiment()
        self.segmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
        self.sliderControl.setValue(50.0, animated: false)
        self.switchControl.setOn(false, animated: false)
        self.textView.text = ""
        
        self.setColors()
    }
    
    func getSentiment() -> Sentiment {
        self.sentiment.elaborate = textView.text
        return self.sentiment
    }
    
    func setSentiment(value: Sentiment?) {
        reset()
        
        switch value?.feeling {
        case "😞":
                self.segmentedControl.selectedSegmentIndex = 0
            break
        case "😐":
            self.segmentedControl.selectedSegmentIndex = 1
            break
        case "😊":
            self.segmentedControl.selectedSegmentIndex = 2
            break
        default:
            self.segmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
            self.segmentedControl.isHidden = true
            self.feelingLabel.isHidden = true
            break
        }
        
        if let intensity = value?.intensity {
            self.sliderControl.setValue(Float(intensity), animated: false)
        } else {
            self.sliderControl.isHidden = true
            self.intensityLabel.isHidden = true
        }
        
        self.colorLabel.isHidden = true
        self.colorButtonControl.isHidden = true
        if let color = value?.color {
            self.setColors(tintColor: color, textColor: color)
        } else {
            self.colorLabel.isHidden = true
        }
        
        if let water = value?.water {
            self.switchControl.setOn(water, animated: false)
        } else {
            self.switchControl.isHidden = true
            self.waterLabel.isHidden = true
        }
        
        if let elaborate = value?.elaborate {
            self.textView.text = elaborate
        } else {
            self.textView.isHidden = true
        }
    }
}

extension QuestionaireView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch != textView {
                textView.resignFirstResponder()
            }
        }
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

extension QuestionaireView {
    
    func showColorPicker() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = (storyboard.instantiateViewController(withIdentifier: ColorPickerViewController.identifier) as? ColorPickerViewController) {
            controller.delegate = self
            navigationController?.setNavigationBarHidden(true, animated: false)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension QuestionaireView: ColorPickerDelegate {
    
    func onColorSelected(_ color: UIColor?) {
        self.sentiment.color = color
        self.setColors(tintColor: color, textColor: color)
    }
    
    func setColors(tintColor: UIColor? = UIView().tintColor, textColor: UIColor? = UIColor.lightGray) {
        self.tintColor = tintColor
        
        // labels
        feelingLabel.textColor = textColor
        intensityLabel.textColor = textColor
        colorLabel.textColor = textColor
        waterLabel.textColor = textColor
        
        // controls
        segmentedControl.tintColor = tintColor
        sliderControl.tintColor = tintColor
        buttonControl.tintColor = tintColor
        switchControl.tintColor = tintColor
    }
}
