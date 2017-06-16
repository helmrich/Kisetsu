//
//  MangaListSelectionViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 11.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class MangaListSelectionViewController: ListSelectionViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AniListClient.shared.getAuthenticatedUser { (user, errorMessage) in
            guard errorMessage == nil else {
                print(errorMessage!)
                return
            }
            
            guard let user = user else {
                print("Couldn't get user")
                return
            }
            
            for mangaListName in MangaListName.allValues {
                AniListClient.shared.getList(ofType: .manga, withStatus: mangaListName.asKey(), userId: user.id, andDisplayName: user.displayName) { (seriesList, errorMessage) in
                    guard errorMessage == nil else {
                        print(errorMessage!)
                        return
                    }
                    
                    guard let seriesList = seriesList else {
                        print("Couldn't get series list for user")
                        return
                    }
                    
                    switch mangaListName {
                    case .reading:
                        DataSource.shared.mangaReadingList = seriesList
                    case .planToRead:
                        DataSource.shared.mangaPlanToReadList = seriesList
                    case .completed:
                        DataSource.shared.mangaCompletedList = seriesList
                    case .onHold:
                        DataSource.shared.mangaOnHoldList = seriesList
                    case .dropped:
                        DataSource.shared.mangaDroppedList = seriesList
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        seriesType = .manga
    }
}
