//
//  BrowseViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 22.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class BrowseViewController: SeriesCollectionViewController {

    // MARK: - Properties
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var seriesCollectionView: UICollectionView!
    @IBOutlet weak var seriesCollectionViewFlowLayout: UICollectionViewFlowLayout!
    
    // MARK: - Actions
    
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorView.startAnimating()
        UIView.animate(withDuration: 0.25) {
            self.activityIndicatorView.alpha = 1
        }
        
        addErrorMessageView(toBottomOf: view, withOffsetToBottom: 49.0, errorMessageView: errorMessageView)
        
        seriesCollectionViewFlowLayout.itemSize = CGSize(width: view.bounds.width / 3 - 0.67, height: view.bounds.width / 3 - 0.67)
        seriesCollectionViewFlowLayout.minimumInteritemSpacing = 1
        seriesCollectionViewFlowLayout.minimumLineSpacing = 1
        
        let parameters: [String:Any] = [
            AniListConstant.ParameterKey.Browse.year: "2015",
//            AniListConstant.ParameterKey.Browse.genres: "Comedy,Romance",
            AniListConstant.ParameterKey.Browse.sort: "score-desc",
//            AniListConstant.ParameterKey.Browse.season: Season.fall.rawValue
        ]
        
        AniListClient.shared.getSeriesList(ofType: .anime, andParameters: parameters) { (seriesList, errorMessage) in
            guard errorMessage == nil else {
                self.errorMessageView.showError(withMessage: errorMessage!)
                return
            }
            
            guard let seriesList = seriesList else {
                self.errorMessageView.showError(withMessage: "Couldn't get series list")
                return
            }
            
            DataSource.shared.browseSeriesList = seriesList
            
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
                UIView.animate(withDuration: 0.25) {
                    self.activityIndicatorView.alpha = 0
                }
                self.seriesCollectionView.reloadData()
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.navigationItem.title = "Browse"
        tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "SettingBarsIcon"), style: .plain, target: self, action: #selector(openFilterModal))
        
        statusBarShouldBeHidden = false
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    
    // MARK: - Functions
    
    func openFilterModal() {
        let filterViewController = storyboard!.instantiateViewController(withIdentifier: "browseFilterViewController") as! BrowseFilterViewController
        filterViewController.modalPresentationStyle = .custom
        filterViewController.transitioningDelegate = self
        UIView.animate(withDuration: 0.5) {
            self.seriesCollectionView.alpha = 0.5
        }
        self.present(filterViewController, animated: true, completion: nil)
    }
    
}

extension BrowseViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return FilterModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
