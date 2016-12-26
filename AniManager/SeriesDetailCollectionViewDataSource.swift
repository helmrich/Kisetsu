//
//  SeriesDetailCollectionViewDataSource.swift
//  AniManager
//
//  Created by Tobias Helmrich on 06.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

extension SeriesDetailViewController: UICollectionViewDataSource {
    /*
        The collection view delegate methods are implemented for the images table view
        cell's collection view
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagesCollectionViewCell", for: indexPath) as! ImagesCollectionViewCell
        
        /*
            Make sure the shared data source's selectedSeries property
            is not nil
         */
        guard let series = DataSource.shared.selectedSeries else {
            return cell
        }
        
        /*
            Set the cell's type property to the same value as its
            collection view's table view cell's type property.
            Note: The first superview property is the table view cell's
            content view, the second one is the actual table view cell.
         */
        if let imagesTableViewCellType = (collectionView.superview?.superview as? ImagesTableViewCell)?.type {
            cell.type = imagesTableViewCellType
        }
        
        /*
            Make sure the series' characters property is not nil and that
            the current character has an URL string for a medium image,
            try downloading and creating an image with the URL string and
            set the cell's image
         */
        guard let characters = series.characters else {
            return cell
        }
        
        guard let imageMediumUrlString = characters[indexPath.row].imageMediumUrlString else {
            return cell
        }
        
        AniListClient.shared.getImageData(fromUrlString: imageMediumUrlString) { (imageData, errorMessage) in
            guard errorMessage == nil else {
                print(errorMessage)
                return
            }
            
            guard let imageData = imageData else {
                print("Couldn't get image data")
                return
            }
            
            guard let image = UIImage(data: imageData) else {
                print("Couldn't create image from image data")
                return
            }
            
            DispatchQueue.main.async {
                cell.imageView.image = image
            }
            
        }
        
        collectionView.reloadItems(at: [indexPath])
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // The number of items should be equal to the number of series characters
        guard let characters = DataSource.shared.selectedSeries?.characters else {
            return 0
        }
        
        return characters.count
        
    }
}
