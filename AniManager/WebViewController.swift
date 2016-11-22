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
        
        setActivityIndicator(enabled: true)
        
        let request = URLRequest(url: url)
        webView.loadRequest(request)
    }
    
    
    // MARK: - Functions

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setActivityIndicator(enabled: Bool) {
        if enabled {
            UIView.animate(withDuration: 0.25, animations: {
                self.activityIndicatorView.alpha = 1
            })
            self.activityIndicatorView.startAnimating()
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.activityIndicatorView.alpha = 0
            })
            self.activityIndicatorView.stopAnimating()
        }
    }

}

extension WebViewController: UIWebViewDelegate {
    // Stop animating the activity indicator and hide it, when the web
    // view did finish loading
    func webViewDidFinishLoad(_ webView: UIWebView) {
        setActivityIndicator(enabled: false)
    }
    
    // Every time the web view starts loading a page,
    // check its request's URL's string and see if it
    // contains "?code=" which implies, that the user
    // approved the authorization request or if contains
    // "?error=access_denied" which implies that the
    // user denied the request.
    
    // This solution is not very clean but the only other
    // way would be to execute the authorization request
    // in the device's default browser instead of in the
    // application itself, so that the redirect URI would
    // open the application again. But because the authorization
    // process should happen in a web view inside of the
    // app this solution is used for now.
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        guard let request = webView.request,
            let url = request.url else {
            return
        }
        
        if url.absoluteString.contains("?code=") {
            // If the URL string contains "?code=" the URL's string should be split
            // up in two components of which the second one will contain the
            // authorization code. Afterwards the shared AniListClient's authorizationCode
            // property should be set to the received authorization code and the
            // web view controller should be dismissed.
            let components = url.absoluteString.components(separatedBy: "?code=")
            let authorizationCode = components[1]
            AniListClient.shared.authorizationCode = authorizationCode
            dismiss(animated: true, completion: nil)
        } else if url.absoluteString.contains("?error=access_denied") {
            // If the URL string contains "?error=access_denied" an error should be
            // displayed on the presenting AuthenticationViewController and the
            // WebViewController should be dismissed
            (presentingViewController as! AuthenticationViewController).errorMessageView.showError(withMessage: "The authorization request was denied")
            dismiss(animated: true, completion: nil)
        }
    }
}
