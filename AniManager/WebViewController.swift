//
//  WebViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 19.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    // MARK: - Properties
    
    var url: URL!
    
    
    // MARK: - Outlets and Actions
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
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

extension WebViewController: UIWebViewDelegate {
    // Show the activity indicator view and animate it
    // when the web view starts loading...
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIView.animate(withDuration: 0.25, animations: {
            self.activityIndicatorView.alpha = 1
        })
        self.activityIndicatorView.startAnimating()
    }
    
    // and stop animating it and hide it, when the web
    // view did finish loading
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIView.animate(withDuration: 0.25, animations: {
            self.activityIndicatorView.alpha = 0
        })
        self.activityIndicatorView.stopAnimating()
    }
}
