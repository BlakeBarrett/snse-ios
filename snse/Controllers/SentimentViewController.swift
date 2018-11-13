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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAndRender()
    }
    
    func fetchAndRender() {
        loadSentiments() { sentiments in
            self.showSentiments(sentiments)
        }
    }
    
    func loadSentiments(_ success: (([Sentiment]) -> Void)?) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        DispatchQueue.global(qos: .background).async {
            let sentiments = SentimentFactory.load(from: context)
            DispatchQueue.main.async {
                success?(sentiments)
            }
        }
    }
    
    func showSentiments(_ sentiments: [Sentiment]) {
        var json = ""
        for value in sentiments {
            json.append("\(value.description), ")
        }
        self.textArea?.text.append(json)
    }
}
