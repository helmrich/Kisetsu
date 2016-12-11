//
//  SeriesCollectionViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 10.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class SeriesCollectionViewController: UIViewController {
    
    // MARK: - Properties
    
    let errorMessageView = ErrorMessageView()
    var statusBarShouldBeHidden = false
    
    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

}


// MARK: - Collection View Data Source

extension SeriesCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let browseSeriesList = DataSource.shared.browseSeriesList else {
            return 0
        }
        
        return browseSeriesList.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "seriesCell", for: indexPath) as! SeriesCollectionViewCell
        
        guard let browseSeriesList = DataSource.shared.browseSeriesList else {
            return cell
        }
        
        if indexPath.row + 1 == browseSeriesList.count {
            print("Collection view reached the end...")
        }
        
        let currentSeries = browseSeriesList[indexPath.row]
        
        if cell.seriesId == nil {
            cell.seriesId = currentSeries.id
        }
        
        if cell.imageView.image == nil {
            AniListClient.shared.getImageData(fromUrlString: currentSeries.imageMediumUrlString) { (imageData, errorMessage) in
                guard errorMessage == nil else {
                    return
                }
                
                guard let imageData = imageData else {
                    return
                }
                
                if let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        cell.imageOverlay.isHidden = false
                        cell.titleLabel.text = currentSeries.titleEnglish
                        cell.titleLabel.isHidden = false
                        cell.imageView.image = image
                    }
                }
            }
        }
        
        return cell
        
    }
}


// MARK: - Collection View Delegate

extension SeriesCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! SeriesCollectionViewCell
        let seriesDetailViewController = storyboard!.instantiateViewController(withIdentifier: "seriesDetailViewController") as! SeriesDetailViewController
        seriesDetailViewController.seriesId = selectedCell.seriesId
        seriesDetailViewController.seriesTitle = selectedCell.titleLabel.text
        seriesDetailViewController.seriesType = .anime
        statusBarShouldBeHidden = true
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        present(seriesDetailViewController, animated: true, completion: nil)
    }
}
