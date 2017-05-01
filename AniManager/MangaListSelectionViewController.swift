//
//  MangaListSelectionViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 11.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class MangaListSelectionViewController: ListSelectionViewController {

    // MARK: - Lifecycle Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let grantTypeString = UserDefaults.standard.string(forKey: "grantType"),
            let grantType = GrantType(rawValue: grantTypeString),
        grantType == .clientCredentials {
            let requiredLoginViewController = RequiredLoginViewController()
            requiredLoginViewController.reason = "watch and manage your manga"
            present(requiredLoginViewController, animated: true, completion: nil)
        }
        
        tabBarController?.navigationItem.title = "Manga Lists"
        tabBarController?.navigationItem.leftBarButtonItem = nil
        
        seriesType = .manga
    }

}
