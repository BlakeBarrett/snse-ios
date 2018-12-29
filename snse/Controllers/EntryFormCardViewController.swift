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
    
    @IBOutlet weak var waterImage: UIImageView!
    @IBOutlet weak var intensitySlider: UISlider!
    @IBOutlet weak var intensityFeelingLabel: UILabel!
    @IBOutlet weak var paletteButton: UIButton!
    @IBOutlet weak var elaborateTextField: UITextField!
    
    var selectedColor: UIColor? = UIColor.white
    
    override func viewDidLoad() {
        elaborateTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    @IBAction func onPalettePressed(_ sender: UIButton) {
        // launch color picker
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = (storyboard.instantiateViewController(withIdentifier: ColorPickerViewController.identifier) as? ColorPickerViewController) {
            weak var weakSelf = self
            controller.delegate = weakSelf
            navigationController?.setNavigationBarHidden(true, animated: false)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension EntryFormCardViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // launch full-screen text editor
    }
}

extension EntryFormCardViewController: ColorPickerDelegate {
    
    func onColorSelected(_ color: UIColor?) {
        self.selectedColor = color
        self.setColors(tintColor: color)
    }
    
    func setColors(tintColor: UIColor? = UIColor.darkGray) {
        view.backgroundColor = tintColor
        view.tintColor = tintColor
        cardView.backgroundColor = UIColor.white
        
        // text field
        elaborateTextField.backgroundColor = UIColor.white
        elaborateTextField.tintColor = tintColor
        
        // controls
        intensitySlider.tintColor = tintColor
        waterImage.tintColor = tintColor
    }
}
