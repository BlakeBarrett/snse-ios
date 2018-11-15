//
//  ColorPickerViewController.swift
//  snse
//
//  Created by Blake Barrett on 11/14/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import Foundation
import UIKit

protocol ColorPickerDelegate {
    func onColorSelected(_ color: UIColor?)
}

class ColorPickerViewController: UIViewController {
    
    @IBOutlet weak var viewHSBColorPicker: HSBColorPicker!
    @IBOutlet weak var colorPreviewView: UIView!
    
    private var color: UIColor?
    var delegate: ColorPickerDelegate?
    
    override func viewDidLoad() {
        viewHSBColorPicker.delegate = self
    }
    
    @IBAction func onCancelPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onDonePressed(_ sender: UIBarButtonItem) {
        self.delegate?.onColorSelected(self.color)
        navigationController?.popViewController(animated: true)
    }
}

extension ColorPickerViewController: HSBColorPickerDelegate {
    
    func HSBColorColorPickerTouched(sender:HSBColorPicker,
                                    color:UIColor, point:CGPoint,
                                    state:UIGestureRecognizer.State) {
        self.colorPreviewView.backgroundColor = color
        self.color = color
    }
}
