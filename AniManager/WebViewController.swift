//
//  WebViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 19.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {

    // MARK: - Properties
    
    var url: URL!
    
    
    // MARK: - Outlets and Actions
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Lifecycle Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let request = URLRequest(url: url)
        webView.loadRequest(request)
    }
    
    
    // MARK: - Functions

    override var prefersStatusBarHidden: Bool {
        return true
    }

}
