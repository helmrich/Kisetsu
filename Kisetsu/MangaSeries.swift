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
    
    // List-specific properties
    var readChapters: Int?
    var readVolumes: Int?
    
    /*
        Override the superclass' initializer, initialize an
        instance from a dictionary, try to get all values that are
        specific to manga from the dictionary and set the manga's
        properties to them. After that call the superclass' initializer
     */
    override init?(fromDictionary dictionary: [String:Any]) {
        
        typealias MangaSeriesKey = AniListConstant.ResponseKey.MangaSeries
        
        guard let numberOfTotalChapters = dictionary[MangaSeriesKey.totalChapters] as? Int else {
            print("Couldn't get number of total chapters")
            return nil
        }
        
        self.numberOfTotalChapters = numberOfTotalChapters
        
        guard let numberOfTotalVolumes = dictionary[MangaSeriesKey.totalVolumes] as? Int else {
            print("Couldn't get number of total volumes")
            return nil
        }
        
        self.numberOfTotalVolumes = numberOfTotalVolumes
        
        if let publishingStatusString = dictionary[MangaSeriesKey.publishingStatus] as? String,
            let publishingStatus = MangaPublishingStatus(rawValue: publishingStatusString) {
            self.publishingStatus = publishingStatus
        } else {
            self.publishingStatus = nil
        }
        
        if let readChapters = dictionary[AniListConstant.ResponseKey.List.MangaList.readChapters] as? Int {
            self.readChapters = readChapters
        } else {
            self.readChapters = nil
        }
        
        if let readVolumes = dictionary[AniListConstant.ResponseKey.List.MangaList.readVolumes] as? Int {
            self.readVolumes = readVolumes
        } else {
            self.readVolumes = nil
        }
        
        super.init(fromDictionary: dictionary)
        
    }
}
