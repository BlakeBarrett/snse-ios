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
            let body = message.body as! String
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
    
    func save(_ value: String, completion: (() -> Void)?) {
        completion?()
    }
    
    func close() {
        dismiss(animated: true, completion: nil)
    }
}
