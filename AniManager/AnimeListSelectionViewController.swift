//
//  AnimeListSelectionViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 11.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class AnimeListSelectionViewController: ListSelectionViewController {
    
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
            
            for animeListName in AnimeListName.allValues {
                AniListClient.shared.getList(ofType: .anime, withStatus: animeListName.asKey(), userId: user.id, andDisplayName: user.displayName) { (seriesList, errorMessage) in
                    guard errorMessage == nil else {
                        print(errorMessage!)
                        return
                    }
                    
                    guard let seriesList = seriesList else {
                        print("Couldn't get series list for user")
                        return
                    }
                    
                    switch animeListName {
                    case .watching:
                        DataSource.shared.animeWatchingList = seriesList
                    case .planToWatch:
                        DataSource.shared.animePlanToWatchList = seriesList
                    case .completed:
                        DataSource.shared.animeCompletedList = seriesList
                    case .onHold:
                        DataSource.shared.animeOnHoldList = seriesList
                    case .dropped:
                        DataSource.shared.animeDroppedList = seriesList
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
        
        if let grantTypeString = UserDefaults.standard.string(forKey: "grantType"),
            let grantType = GrantType(rawValue: grantTypeString),
            grantType == .clientCredentials {
            let requiredLoginViewController = RequiredLoginViewController()
            requiredLoginViewController.reason = "watch and manage your manga"
            present(requiredLoginViewController, animated: true, completion: nil)
        }
        
        seriesType = .anime
    }

}
