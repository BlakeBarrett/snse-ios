//
//  HistoricalSentimentViewController.swift
//  snse
//
//  Created by Blake Barrett on 11/14/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import Foundation
import UIKit

class HistoricalSentimentViewController: UIViewController {
    
    static let storyboardId = "historicalSentimentView"
    static let identifier = "historyViewController"
    
    var sentiment: Sentiment?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM, dd hh:mm"
        let when = dateFormatter.string(from: self.sentiment?.timestamp ?? Date())
        self.title = when
        self.navigationController?.title = when
    }
}
