//
//  SeriesCollectionViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 10.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class SeriesCollectionViewController: UIViewController {
    
    /*
        The SeriesCollectionViewController class will be used
        as a superclass for most classes that will display
        series items in a collection view.
     
        It provides common properties and functionality such as
        an error message view, properties for the status bar's
        display status, a basic implementation of the collection
        view delegate and a configuration method for the series
        collection view flow layout
     */
    
    // MARK: - Properties
    
    var seriesType: SeriesType! = .anime
    
    let errorMessageView = ErrorMessageView()
    var statusBarShouldBeHidden = false
    
    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addErrorMessageViewToBottomOfView(withOffsetToBottom: -49.0, errorMessageView: errorMessageView)
        navigationController?.navigationBar.barStyle = .blackTranslucent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        statusBarShouldBeHidden = false
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    
    // MARK: - Functions
    
    func configure(_ seriesCollectionViewFlowLayout: UICollectionViewFlowLayout) {
        if view.bounds.width > 414.0 {
            seriesCollectionViewFlowLayout.itemSize = CGSize(width: (view.bounds.width / 6) - 0.84, height: (view.bounds.width / 6) - 0.84)
            seriesCollectionViewFlowLayout.minimumInteritemSpacing = 1
            seriesCollectionViewFlowLayout.minimumLineSpacing = 1
        } else {
            seriesCollectionViewFlowLayout.itemSize = CGSize(width: view.bounds.width / 3 - 0.67, height: view.bounds.width / 3 - 0.67)
            seriesCollectionViewFlowLayout.minimumInteritemSpacing = 1
            seriesCollectionViewFlowLayout.minimumLineSpacing = 1
        }
    }
}


// MARK: - Collection View Delegate

extension SeriesCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! SeriesCollectionViewCell
        let seriesDetailViewController = storyboard!.instantiateViewController(withIdentifier: "seriesDetailViewController") as! SeriesDetailViewController
        seriesDetailViewController.seriesId = selectedCell.seriesId
        seriesDetailViewController.seriesTitle = selectedCell.titleLabel.text
        seriesDetailViewController.seriesType = seriesType
        statusBarShouldBeHidden = true
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        present(seriesDetailViewController, animated: true, completion: nil)
    }
}
