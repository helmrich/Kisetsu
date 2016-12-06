//
//  HomeViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 22.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    let errorMessageView = ErrorMessageView()
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    // MARK: - Actions
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addErrorMessageView(toBottomOf: view, errorMessageView: errorMessageView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        tabBarController?.navigationItem.title = "AniManager"
        tabBarController?.navigationItem.leftBarButtonItem = nil
    }
    
    
    // MARK: - Functions
    
    
}
