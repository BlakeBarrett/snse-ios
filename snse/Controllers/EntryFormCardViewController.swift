//
//  EntryFormCardViewController.swift
//  snse
//
//  Created by Blake Barrett on 12/23/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import UIKit

class EntryFormCardViewController: UIViewController {
    
    @IBOutlet weak var cardView: UICardView!
    
    @IBOutlet weak var feelingView: FeelingEntryView!
    @IBOutlet weak var waterImage: UIButton!
    @IBOutlet weak var intensitySlider: UISlider!
    @IBOutlet weak var paletteButton: UIButton!
    @IBOutlet weak var elaborateTextField: UITextField!
    
    var selectedColor: UIColor? = UIColor.white
    var selectedFeelingIndex: Int = -1
    
    override func viewDidLoad() {
        elaborateTextField.delegate = self
        waterImage.tintColor = self.view.tintColor
        feelingView.selectedColor = self.view.tintColor
        updateFeelingIntensity(value: 50)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    @IBAction func onPalettePressed(_ sender: UIButton) {
        catchTheFeeling()
        // launch color picker
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = (storyboard.instantiateViewController(withIdentifier: ColorPickerViewController.identifier) as? ColorPickerViewController) {
            weak var weakSelf = self
            controller.color = selectedColor
            controller.delegate = weakSelf
            navigationController?.setNavigationBarHidden(true, animated: false)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func onWaterButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    @IBAction func onIntensitySliderChange(_ sender: UISlider) {
        updateFeelingIntensity(value: Int(sender.value))
    }
}

extension EntryFormCardViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // launch full-screen text editor
        textField.resignFirstResponder()
        let controller = DedicatedTextEntryViewController.show(in: self.navigationController)
        controller?.delegate = self
        controller?.prepopulateText(with: textField.text)
    }
}

extension EntryFormCardViewController: TextEntryDelegate {
    func updateText(with value: String?) {
        elaborateTextField.text = value
    }
}

extension EntryFormCardViewController: ColorPickerDelegate {
    
    func onColorSelected(_ color: UIColor?) {
        self.selectedColor = color
        self.setColors(tintColor: color)
        setTheFeeling()
    }
    
    func setColors(tintColor: UIColor? = UIColor.darkGray) {
        view.backgroundColor = tintColor
        view.tintColor = tintColor
        cardView.backgroundColor = UIColor.white
        
        // feeling
        feelingView.selectedColor = tintColor
        
        // text field
        elaborateTextField.backgroundColor = UIColor.white
        elaborateTextField.tintColor = tintColor
        
        // controls
        intensitySlider.tintColor = tintColor
        waterImage.tintColor = tintColor
        
        // outline around the textfield
        elaborateTextField.layer.borderColor = tintColor?.cgColor
        elaborateTextField.layer.borderWidth = 1.0
        elaborateTextField.layer.cornerRadius = 3.0
    }
}

extension EntryFormCardViewController {
    func getTheFeeling() -> String? {
        return feelingView.selectedFeeling
    }
    
    func catchTheFeeling() {
        selectedFeelingIndex = feelingView.selectedIndex
    }
    
    func setTheFeeling() {
        feelingView.selectedIndex = selectedFeelingIndex
    }
    
    func updateFeelingIntensity(value: Int) {
        feelingView.intensity = value
    }
}

extension EntryFormCardViewController {
    func sentiment() -> Sentiment? {
        var values = [String : Any]()
        values[Sentiment.Fields.feeling.rawValue] = getTheFeeling()
        values[Sentiment.Fields.water.rawValue] = waterImage.isSelected
        values[Sentiment.Fields.intensity.rawValue] = intensitySlider.value
        values[Sentiment.Fields.elaborate.rawValue] = elaborateTextField.text
        values[Sentiment.Fields.color.rawValue] = selectedColor
        
        return Sentiment(values: values)
    }
}
