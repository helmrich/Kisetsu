//
//  MangaSeries.swift
//  AniManager
//
//  Created by Tobias Helmrich on 24.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

class MangaSeries: Series {
    let numberOfTotalChapters: Int
    let numberOfTotalVolumes: Int
    let publishingStatus: MangaPublishingStatus?
    
    /*
        Override the superclass' initializer, initialize an
        instance from a dictionary, try to get all values that are
        specific to manga from the dictionary and set the manga's
        properties to them. After that call the superclass' initializer
     */
    override init?(fromDictionary dictionary: [String:Any]) {
        guard let numberOfTotalChapters = dictionary["total_chapters"] as? Int else {
            print("Couldn't get number of total chapters")
            return nil
        }
        
        self.numberOfTotalChapters = numberOfTotalChapters
        
        guard let numberOfTotalVolumes = dictionary["total_volumes"] as? Int else {
            print("Couldn't get number of total volumes")
            return nil
        }
        
        self.numberOfTotalVolumes = numberOfTotalVolumes
        
        if let publishingStatusString = dictionary["publishing_status"] as? String,
            let publishingStatus = MangaPublishingStatus(rawValue: publishingStatusString) {
            self.publishingStatus = publishingStatus
        } else {
            self.publishingStatus = nil
        }
        
        super.init(fromDictionary: dictionary)
        
    }
}
