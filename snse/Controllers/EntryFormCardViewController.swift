//
//  EntryFormCardViewController.swift
//  snse
//
//  Created by Blake Barrett on 12/23/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import UIKit

@IBDesignable
class EntryFormCardViewController: UIViewController {
    
    @IBOutlet weak var cardView: UICardView!
    
    @IBOutlet weak var feelingView: FeelingEntryView!
    @IBOutlet weak var waterImage: UIBarButtonItem!
    @IBOutlet weak var intensitySlider: UISlider!
    @IBOutlet weak var paletteButton: UIButton!
    @IBOutlet weak var elaborateTextField: UITextField!
    
    var selectedColor: UIColor? = UIColor.white
    var selectedFeelingIndex: Int = -1
    
    override func viewDidLoad() {
        reset()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    @IBAction func onPalettePressed(_ sender: UIButton) {
        catchTheFeeling()
        // launch color picker
        
        if let controller = UIViewController.show(viewWithId: ColorPickerViewController.identifier,
                                                  in: navigationController) as? ColorPickerViewController {
            weak var weakSelf = self
            controller.delegate = weakSelf
            controller.color = selectedColor
        }
    }
    
    @IBAction func onWaterButtonPressed(_ sender: UIBarButtonItem) {
        if (sender.tag == 0) {
            sender.tag = 1
        } else {
            sender.tag = 0
        }
        updateWaterButtonImage(sender)
    }
    
    func updateWaterButtonImage(_ sender: UIBarButtonItem) {
        let imageName = "water\(sender.tag == 0 ? "-off" : "")"
        sender.image = UIImage(named: imageName)
    }
    
    @IBAction func onIntensitySliderChange(_ sender: UISlider) {
        updateFeelingIntensity(value: Int(sender.value))
    }
}

extension EntryFormCardViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // launch full-screen text editor
        textField.resignFirstResponder()
        if let controller = UIViewController.show(viewWithId: DedicatedTextEntryViewController.identifier,
                                                  in: self.navigationController) as? DedicatedTextEntryViewController {
            weak var weakSelf = self
            controller.delegate = weakSelf
            controller.prepopulateText(with: textField.text)
        }
    }
}

extension EntryFormCardViewController: TextEntryDelegate {
    
    func saveWasCalled(with value: String?) {
        elaborateTextField.text = value
        
        save()
    }
    
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
    
    func save() {
        if let sentiment = sentiment() {
            SentimentFactory.save(sentiment)
            reset()
        }
    }
    
    func reset() {
        elaborateTextField.text = ""
        selectedColor = UIColor.white
        waterImage.tag = 0
        updateWaterButtonImage(waterImage)
        feelingView.reset()
        setColors(tintColor: UIColor.darkGray)
        view.backgroundColor = UIColor.groupTableViewBackground
        updateFeelingIntensity(value: 50)
    }
    
    func sentiment() -> Sentiment? {
        var values = [String : Any]()
        values[Sentiment.Fields.feeling.rawValue] = getTheFeeling()
        values[Sentiment.Fields.water.rawValue] = waterImage.tag == 1
        values[Sentiment.Fields.intensity.rawValue] = Int(intensitySlider.value)
        values[Sentiment.Fields.elaborate.rawValue] = elaborateTextField.text
        
        let value = Sentiment(values: values)
        // for some reason, I wasn't able to pass a UIColor through the values
        //  dictionary and have it work.
        // ¯\_(ツ)_/¯
        value?.color = selectedColor
        return value
    }
}
