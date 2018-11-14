//
//  SentimentViewController.swift
//  snse
//
//  Created by Blake Barrett on 11/10/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import Foundation
import UIKit

class SentimentViewController: UITableViewController {
    
    var sentiments = [Sentiment]()
    var reuseIdentifier = "sentimentTableViewCellReuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "SentimentTableViewCell", bundle: Bundle.main)
        tableView.register(cellNib, forCellReuseIdentifier: reuseIdentifier)
        tableView.estimatedRowHeight = 300
        fetchAndRender()
    }
    
    func fetchAndRender() {
        loadSentiments() { sentiments in
            self.showSentiments(sentiments)
        }
    }
    
    func loadSentiments(_ success: (([Sentiment]) -> Void)?) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        // db on the background
        DispatchQueue.global(qos: .background).async {
            self.sentiments = SentimentFactory.load(from: context)
            // ui on the main thread
            DispatchQueue.main.async {
                success?(self.sentiments)
            }
        }
    }
    
    func showSentiments(_ sentiments: [Sentiment]) {
        tableView.reloadData()
    }
}

extension SentimentViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sentiments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SentimentTableViewCell
        cell.prepareForReuse()
        let row = self.sentiments[indexPath.row]
        cell.set(row)
        return cell
    }
}

class SentimentTableViewCell: UITableViewCell {
    
    /*
     timestamp = "timestamp",
     water = "water",
     elaborate = "elaborate",
     feeling = "feeling",
     color = "color"
    */
    
    @IBOutlet weak var feelingLabel: UILabel!
    @IBOutlet weak var waterSwitch: UISwitch!
    @IBOutlet weak var dateLabel: UILabel!
    
    func set(_ value: Sentiment) {
        feelingLabel.text = value.feeling
        
        waterSwitch.setOn(value.water, animated: false)
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, hh:mm"
        
        dateLabel.text = dateFormatterPrint.string(from: value.timestamp!)
    }
}
