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
        
        static let select = NSLocalizedString("Select", comment: "Select")
        static let selectAll = NSLocalizedString("Select All", comment: "Select All")
        static let filter = NSLocalizedString("Filter", comment: "Filter")
        
        static var actionBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                         target: self,
                                                         action: #selector(handleAction))
        static var selectBarButtonItem = UIBarButtonItem(title: Constants.select,
                                                         style: .plain,
                                                         target: self,
                                                         action: #selector(handleSelectButton(_:)))
        static var cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                         target: self,
                                                         action: #selector(handleSelectButton(_:)))
        static var selectAllButtonItem = UIBarButtonItem(title: Constants.selectAll,
                                                         style: .plain,
                                                         target: self,
                                                         action: #selector(handleSelectAll))
        static var trashBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash,
                                                         target: self,
                                                         action: #selector(handleTrash))
    }
    
    var sentiments = [Sentiment]()
    var detailView: DetailCardViewController? = DetailCardViewController()
    
    var selectedItems: [Sentiment]? {
        get {
            return tableView.indexPathsForSelectedRows?.compactMap { indexPath in
                self.sentiments[indexPath.row]
            }
        }
    }
    
    deinit {
        detailView?.sentiment = nil
        detailView = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.interactions.append(UIDropInteraction(delegate: self))
        
        configureTableView(tableView: tableView)
        
        configureNavigationItem(navigationItem: navigationItem)
        
        fetchAndRender()
    }
    
    func configureTableView(tableView: UITableView) {
        let cellNib = UINib(nibName: SentimentTableViewCell.nibIdentifier, bundle: Bundle.main)
        tableView.register(cellNib, forCellReuseIdentifier: SentimentTableViewCell.reuseIdentifier)
        tableView.estimatedRowHeight = 75
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self,
                                            action: #selector(handleRefreshControl),
                                            for: .valueChanged)
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    func configureNavigationItem(navigationItem: UINavigationItem,
                                 selectItem: UIBarButtonItem = Constants.selectBarButtonItem) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = Constants.filter
        searchController.searchBar.setShowsCancelButton(true, animated: false)
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationItem.rightBarButtonItem = selectItem
        
        definesPresentationContext = true
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
    
    @objc func handleRefreshControl() {
        fetchAndRender()
    }
    
    @objc func handleSelectButton(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
        
        navigationItem.rightBarButtonItem = nil
        navigationItem.rightBarButtonItems = nil
        
        if tableView.isEditing {
            
            navigationItem.leftBarButtonItem = Constants.cancelBarButtonItem
            
            // Because in macCatalyts where you cannot "Select All", nor can you swipe to delete
            #if targetEnvironment(macCatalyst)
                navigationItem.rightBarButtonItems = [Constants.actionBarButtonItem, Constants.trashBarButtonItem]
            #else
                navigationItem.rightBarButtonItem = Constants.selectAllButtonItem
            #endif
            
        } else {
            
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = Constants.selectBarButtonItem
        }
    }
    
    @objc func handleSelectAll() {
        self.sentiments.enumerated().forEach { (index, sentiment) in
            
            let indexPath = IndexPath(row: index, section: 0)
            
            tableView.selectRow(at: indexPath,
                                animated: false,
                                scrollPosition: UITableView.ScrollPosition.none)
        }
        
        navigationItem.rightBarButtonItem = Constants.actionBarButtonItem
    }
    
    @objc func handleTrash() {
        selectedItems?.forEach { sentiment in
            _ = SentimentFactory.delete(sentiment)
        }
        
        fetchAndRender()
        
        handleSelectButton(self)
    }
    
    @objc func handleAction() {
        
        guard let items = selectedItems else { return }
        
        guard let json = jsonString(for: items) else { return }
        
        let savedFileUrl = getTempFilePath()
        writeFile(with: json, to: savedFileUrl)
        
        self.present(
            UIActivityViewController(
                activityItems: [savedFileUrl],
                applicationActivities: nil),
            animated: true)
    }
    
    private func jsonString(for items: [Sentiment]) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let encoded = try? encoder.encode(items) else { return nil }
        
        let value = String(decoding: encoded, as: UTF8.self)
        
        return value
    }
    
    private func getTempFilePath() -> URL {
        let filename = "snse-\(Date().timeIntervalSince1970).json"
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempFileUrl = tempDirectory.appendingPathComponent(filename)
        
        return tempFileUrl
    }
    
    private func writeFile(with contents: String, to url: URL) {
        try? contents.data(using: .utf8)?.write(to: url, options: .atomic)
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
        if !tableView.isEditing {
            let value = self.sentiments[indexPath.row]
            showHistoricalSentiment(value)
            
            if  #available(iOS 11.0, *),
                navigationItem.searchController?.isActive ?? false {
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            
            if selectedItems?.count == 0 {
                navigationItem.rightBarButtonItem = Constants.selectAllButtonItem
            } else {
                navigationItem.rightBarButtonItem = Constants.actionBarButtonItem
            }
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            didDeselectRowAt indexPath: IndexPath) {
        
        guard tableView.isEditing else { return }
        
        if selectedItems?.count == 0 {
            navigationItem.rightBarButtonItem = Constants.selectAllButtonItem
        } else {
            navigationItem.rightBarButtonItem = Constants.actionBarButtonItem
        }
    }
    
    func showHistoricalSentiment(_ value: Sentiment) {
        guard let detailView = detailView else { return }
        detailView.sentiment = value
        self.definesPresentationContext = false
        show(detailView, modally: true, animated: true)
    }
    
    override func tableView(_ tableView: UITableView,
                            canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
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

extension SentimentViewController: UIDropInteractionDelegate {
    
    static let JSONTypeIdentifier = "public.json"
    
    func dropInteraction(_ interaction: UIDropInteraction,
                         canHandle session: UIDropSession) -> Bool {
        return session.hasItemsConforming(toTypeIdentifiers: [SentimentViewController.JSONTypeIdentifier])
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    // Thank you @Asperi on StackOverflow: https://stackoverflow.com/a/65211685/659746
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.items.forEach { item in
            item.itemProvider.registeredTypeIdentifiers.forEach { itemType in
                guard item.itemProvider.hasItemConformingToTypeIdentifier(itemType) else { return }
                item.itemProvider.loadDataRepresentation(forTypeIdentifier: itemType) { data, error in
                    if let data = data {
                        self.importJSONData(from: data)
                    }
                }
            }
        }
    }
    
    private func importJSONData(from data: Data) {
        guard let values = SentimentFactory.arrayFrom(data: data) else { return }
        DispatchQueue.global(qos: .background).async {
            // Save on a background thread
            SentimentFactory.save(values)
            // ui on the main thread
            DispatchQueue.main.async {
                self.fetchAndRender()
            }
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
        
        self.backgroundColor = UIColor.white
    }
}
