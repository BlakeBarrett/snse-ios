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
    
    static let identifier = "historyViewController"
    
    var sentiments = [Sentiment]()
    var detailView: DetailCardViewController? = DetailCardViewController()
    
    deinit {
        detailView?.sentiment = nil
        detailView = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: SentimentTableViewCell.nibIdentifier, bundle: Bundle.main)
        tableView.register(cellNib, forCellReuseIdentifier: SentimentTableViewCell.reuseIdentifier)
        tableView.estimatedRowHeight = 75
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            let searchController = UISearchController(searchResultsController: nil)
            searchController.searchResultsUpdater = self
            searchController.definesPresentationContext = true
            navigationItem.searchController = searchController
        }
        
        fetchAndRender()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setLargeTitleMode(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setLargeTitleMode(false)
    }
    
    func fetchAndRender(filter: String? = nil) {
        loadSentiments(filter: filter) { sentiments in
            self.showSentiments(sentiments)
        }
    }
    
    func loadSentiments(filter: String?, _ success: (([Sentiment]) -> Void)?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        // db on the background
        DispatchQueue.global(qos: .background).async {
            self.sentiments = SentimentFactory.load(from: context, filter: filter)
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
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: SentimentTableViewCell.reuseIdentifier, for: indexPath)
        if let cell = reusableCell as? SentimentTableViewCell {
            cell.prepareForReuse()
            let row = self.sentiments[indexPath.row]
            cell.set(row)
            return cell
        }
        return reusableCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = self.sentiments[indexPath.row]
        showHistoricalSentiment(value)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func showHistoricalSentiment(_ value: Sentiment) {
        guard let detailView = detailView else { return }
        detailView.sentiment = value
        show(detailView, modally: true, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if  editingStyle == .delete {
            let sentiment = sentiments[indexPath.row]
            if SentimentFactory.delete(sentiment) {
                sentiments.remove(at: indexPath.row)
                tableView.reloadData()
            }
        }
    }
    
}

extension SentimentViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if  searchController.isActive,
            let filter = searchController.searchBar.text,
            !"".elementsEqual(filter) {
            fetchAndRender(filter: filter)
        } else {
            fetchAndRender()
        }
    }
}

class SentimentTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "sentimentTableViewCellReuseIdentifier"
    static let nibIdentifier = "SentimentTableViewCell"
    
    @IBOutlet weak var feelingLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var elaborateTextView: UITextView!
    @IBOutlet weak var colorView: UIView!
    
    func set(_ value: Sentiment) {
        accessoryType = .disclosureIndicator
        
        feelingLabel.text = value.feeling
        
        elaborateTextView.text = value.elaborate
        
        dateLabel.text = value.getDateString()
        
        colorView.backgroundColor = value.color
    }
}
