//
//  SentimentViewController.swift
//  snse
//
//  Created by Blake Barrett on 11/10/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import Foundation
import UIKit

class SentimentViewController: UIViewController {
    
    @IBOutlet weak var textArea: UITextView?
    
    var sentiments: [Sentiment]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.sentiments = SentimentFactory.load(from: context)
            var json = ""
            for value in self.sentiments ?? [] {
                json.append("\(value.description), ")
            }
            DispatchQueue.main.async {
                self.textArea?.text.append(json)
            }
        }
    }
}
