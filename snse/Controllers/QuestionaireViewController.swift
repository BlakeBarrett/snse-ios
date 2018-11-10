//
//  QuestionaireViewController.swift
//  snse
//
//  Created by Blake Barrett on 11/8/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import CoreData

class QuestionaireViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    let messageChannel = "bridge"
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.configuration.userContentController.add(self, name: messageChannel)
        
        if let sourcePath = Bundle.main.path(forResource: "index", ofType: "html") {
            let url = URL(fileURLWithPath: sourcePath)
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == messageChannel {
            let body = message.body as! [String : Any]
            print(body)
            save(body) {
                self.close()
            }
        }
    }
    
    @IBAction func onDonePressed(_ sender: Any) {
        webView.stopLoading()
        webView.uiDelegate = nil
        webView.navigationDelegate = nil
        webView.configuration.userContentController.removeScriptMessageHandler(forName: messageChannel)
        
        close()
    }
    
    func save(_ values: [String : Any], completion: (() -> Void)?) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Sentiment", in: context)
        let sentiment = NSManagedObject(entity: entity!, insertInto: context)
        
        for (key, value) in values {
            
            switch key {
            case "timestamp":
                if  let epoch = value as? Int,
                    let timeInterval = TimeInterval(exactly: epoch / 1000) {
                    let epochDate = Date(timeIntervalSince1970: timeInterval)
                    sentiment.setValue(epochDate, forKey: key)
                }
                break
            case "water": // absent if deselected
                sentiment.setValue(true, forKey: key)
                break
            default:
                sentiment.setValue(value, forKey: key)
                break
            }
        }
        
        do {
            try context.save()
        } catch {
            return
        }
        completion?()
    }
    
    func close() {
        dismiss(animated: true, completion: nil)
    }
}
