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
    @IBOutlet weak var paletteImage: UIImageView!
    @IBOutlet weak var elaborateTextField: UITextField!
    
    
    let imageTapGestureRecognizer = UIGestureRecognizer(target: self,
                                                        action: Selector(("onPaletteTouch:")))
    
    override func viewDidLoad() {
        addTouchListeners()
        elaborateTextField.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeTouchListeners()
    }
    
    func addTouchListeners() {
        paletteImage.addGestureRecognizer(imageTapGestureRecognizer)
    }
    
    func removeTouchListeners() {
        paletteImage.removeGestureRecognizer(imageTapGestureRecognizer)
    }
    
    func onPaletteTouch(recognizer: UIGestureRecognizer) {
        // launch color picker
    }
}

extension EntryFormCardViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // launch full-screen text editor
    }
}
