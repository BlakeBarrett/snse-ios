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
    
    struct Constants {
        static let cancel = NSLocalizedString("Cancel", comment: "Cancel")
        static let select = NSLocalizedString("Select", comment: "Select")
        static let filter = NSLocalizedString("Filter", comment: "filter")
    }
    
    var sentiments = [Sentiment]()
    var detailView: DetailCardViewController? = DetailCardViewController()
    var selectedItems = Set<Sentiment>()
    
    lazy var actionBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action,
                                                   target: self,
                                                   action: #selector(handleAction))
    lazy var selectBarButtonItem = UIBarButtonItem(title: Constants.select,
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(handleSelectButton))
    lazy var cancelBarButtonItem = UIBarButtonItem(title: Constants.cancel,
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(handleSelectButton))
    
    deinit {
        detailView?.sentiment = nil
        detailView = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: SentimentTableViewCell.nibIdentifier, bundle: Bundle.main)
        tableView.register(cellNib, forCellReuseIdentifier: SentimentTableViewCell.reuseIdentifier)
        tableView.estimatedRowHeight = 75
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self,
                                            action: #selector(handleRefreshControl),
                                            for: .valueChanged)
        tableView.allowsMultipleSelectionDuringEditing = true
        
        if #available(iOS 11.0, *) {

            navigationItem.searchController = UISearchController(searchResultsController: nil)
            navigationItem.searchController?.searchResultsUpdater = self
            navigationItem.searchController?.searchBar.placeholder = Constants.filter
            navigationItem.searchController?.searchBar.setShowsCancelButton(false, animated: false)
            navigationItem.hidesSearchBarWhenScrolling = true
            
            navigationItem.rightBarButtonItem = selectBarButtonItem
        
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
        tableView.refreshControl?.endRefreshing()
    }
}

extension SentimentViewController {
    
    @objc func handleSelectButton() {
        tableView.isEditing = !tableView.isEditing
        if tableView.isEditing {
            
            navigationItem.leftBarButtonItem = cancelBarButtonItem
            navigationItem.rightBarButtonItem = nil
            
        } else {
            
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = selectBarButtonItem
            
        }
    }
    
    @objc func handleAction() {
        
        let encoder = JSONEncoder()
        
        guard let encoded = try? encoder.encode(Array(selectedItems)) else { return }
        
        let value = String(decoding: encoded, as: UTF8.self)
        
        // TODO: create a UIActivityItemProvider describing that this is string/json content
        
        self.present(UIActivityViewController(activityItems: [value],
                                              applicationActivities: nil),
                     animated: true)
    }
    
    @objc func handleRefreshControl() {
        fetchAndRender()
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
        selectedItems.insert(value)
        
        if !tableView.isEditing {
            showHistoricalSentiment(value)
            
            if  #available(iOS 11.0, *),
                navigationItem.searchController?.isActive ?? false {
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
        } else {
            
            navigationItem.rightBarButtonItem = actionBarButtonItem
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let value = self.sentiments[indexPath.row]
        selectedItems.remove(value)
    }
    
    func showHistoricalSentiment(_ value: Sentiment) {
        guard let detailView = detailView else { return }
        detailView.sentiment = value
        self.definesPresentationContext = false
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
