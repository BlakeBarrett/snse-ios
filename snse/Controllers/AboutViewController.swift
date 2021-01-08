//
//  AboutViewController.swift
//  snse
//
//  Created by Blake Barrett on 1/7/21.
//  Copyright © 2021 Blake Barrett. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class AboutViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var webview: WKWebView?
    
    override func viewDidLoad() {
        
        navigationItem.title = "About"
        
        webview = WKWebView(frame: view.frame,
                            configuration: WKWebViewConfiguration())
        
        if let webview = webview {
            webview.navigationDelegate = self
            webview.uiDelegate = self
            
            view.addSubview(webview)

            if let html = htmlContentsString() {
                DispatchQueue.main.async {
                    webview.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
                }
            }
        }
    }
    
    func htmlContentsString() -> String? {
        if let path = Bundle.main.path(forResource: "about", ofType: "html") {
            do {
                return try String(contentsOfFile: path)
            } catch {
                
            }
        }
        return nil
    }
}
