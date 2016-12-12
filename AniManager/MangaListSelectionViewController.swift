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
        
        tabBarController?.navigationItem.title = "Manga Lists"
        tabBarController?.navigationItem.leftBarButtonItem = nil
        
        seriesType = .manga
    }

}
