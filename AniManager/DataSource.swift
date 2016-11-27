//
//  DataSource.swift
//  AniManager
//
//  Created by Tobias Helmrich on 25.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class DataSource {
    
    // MARK: - Properties
    
    static let shared = DataSource()
    
    var browseSeriesList: [Series]? = nil
//    var browseSeriesImages = [IndexPath:UIImage]()
    
    
    // MARK: Initializers
    
    fileprivate init() {}
    
    
    // MARK: - Methods
    
    func getBrowseSeriesList(ofType type: SeriesType, withParameters parameters: [String:Any], completionHandlerForBrowseSeriesList: @escaping (_ errorMessage: String?) -> Void) {
        AniListClient.shared.getSeriesList(ofType: type, andParameters: parameters) { (seriesList, errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForBrowseSeriesList(errorMessage!)
                return
            }
            
            guard let seriesList = seriesList else {
                completionHandlerForBrowseSeriesList("Couldn't get series list")
                return
            }
            
            self.browseSeriesList = seriesList
            
            completionHandlerForBrowseSeriesList(nil)
            
        }
    }
    
    func getImage(forCellAtIndexPath indexPath: IndexPath, completionHandlerForCellImage: @escaping (_ image: UIImage?, _ errorMessage: String?) -> Void) {
        
        print("Inserting image at index path \(indexPath)...")
        
        guard let seriesList = DataSource.shared.browseSeriesList else {
            return
        }
        
        let series = seriesList[indexPath.row]
        
        AniListClient.shared.getImageData(fromUrlString: series.imageMediumUrlString) { (imageData, errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForCellImage(nil, errorMessage!)
                return
            }
            
            guard let imageData = imageData else {
                completionHandlerForCellImage(nil, "Couldn't get image data")
                return
            }
            
            if let image = UIImage(data: imageData) {
                completionHandlerForCellImage(image, nil)
            } else {
                completionHandlerForCellImage(nil, "Couldn't create image from received data")
            }
            
        }
    }
    
}
