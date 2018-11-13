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
        self.tableView.register(cellNib, forCellReuseIdentifier: reuseIdentifier)
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
     url = "url"
    */
    
    @IBOutlet weak var feelingLabel: UILabel!
    @IBOutlet weak var elaborateTextView: UITextView!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var waterSwitch: UISwitch!
    
    func set(_ value: Sentiment) {
        feelingLabel.text = value.feeling
        urlLabel.text = value.url
        waterSwitch.isOn = Bool(value.water)
        elaborateTextView.text = value.elaborate
    }
}
