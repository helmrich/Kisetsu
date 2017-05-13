//
//  NetworkActivityManager.swift
//  AniManager
//
//  Created by Tobias Helmrich on 29.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation
import UIKit

class NetworkActivityManager {
    
    /*
        This class is supposed to keep track of the
        number of currently active network connections.
     
        It was mainly implemented because there was
        a problem with the status bar's network
        activity indicator and asynchronous methods
        which was that after the first asynchronous
        block was finished the network connection
        indicator was hiding even when there were
        other network requests that were still active.
        
        By checking this classes' numberOfActiveConnections
        property the status of the status bar's
        network indicator's visibility can be set
        appropriately
     */
    
    var numberOfActiveConnections = 0 {
        didSet {
            if numberOfActiveConnections < 0 {
                numberOfActiveConnections = 0
            }
        }
    }
    
    static let shared = NetworkActivityManager()
    fileprivate init() {}
    
    func increaseNumberOfActiveConnections() {
        numberOfActiveConnections += 1
        setupStatusBarActivityIndicator()
    }
    
    func decreaseNumberOfActiveConnections() {
        numberOfActiveConnections -= 1
        setupStatusBarActivityIndicator()
    }
    
    func setupStatusBarActivityIndicator() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
        }
    }
    
}
