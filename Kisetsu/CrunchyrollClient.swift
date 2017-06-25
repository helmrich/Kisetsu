//
//  CrunchyrollClient.swift
//  Kisetsu
//
//  Created by Tobias Helmrich on 24.06.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import Foundation
import FeedKit

class CrunchyrollClient {
    // Singleton
    static let shared = CrunchyrollClient()
    fileprivate init() {}
}

extension CrunchyrollClient {
    func getEpisodeList(forSeriesCrunchyrollURLString urlString: String, completionHandlerForEpisodeList: @escaping (_ episodeList: [Episode]?, _ errorMessage: String?) -> Void) {
        guard let url = createSecureURL(fromURLString: "\(urlString).rss") else {
            completionHandlerForEpisodeList(nil, "Couldn't get URL for anime series")
            return
        }
        
        guard let feedParser = FeedParser(URL: url) else {
            completionHandlerForEpisodeList(nil, "Couldn't create feed parser")
            return
        }
        
        feedParser.parseAsync { (result) in
            guard result.isSuccess else {
                completionHandlerForEpisodeList(nil, "Couldn't parse episode feed")
                return
            }
            
            guard let rssFeed = result.rssFeed else {
                completionHandlerForEpisodeList(nil, "Couldn't get RSS feed from results")
                return
            }
            
            var episodeList = [Episode]()
            rssFeed.items?.forEach { rssFeedItem in
                let episodeTitle: String
                let episodeDescription: String
                let previewImageURL: URL?
                let crunchyrollURL: URL?
                
                episodeTitle = rssFeedItem.title ?? "No title available"
                episodeDescription = self.getEpisodeDescription(fromDescription: rssFeedItem.description) ?? "No description available"
                previewImageURL = self.getImageURL(fromDescription: rssFeedItem.description)
                if let rssFeedItemLink = rssFeedItem.link {
                    crunchyrollURL = URL(string: rssFeedItemLink)
                } else {
                    crunchyrollURL = nil
                }
                
                let episode = Episode(title: episodeTitle, description: episodeDescription, crunchyrollURL: crunchyrollURL, previewImageURL: previewImageURL)
                episodeList.append(episode)
            }
            
            if let selectedAnimeSeries = DataSource.shared.selectedSeries as? AnimeSeries {
                selectedAnimeSeries.episodes = episodeList
            }
            
            completionHandlerForEpisodeList(episodeList, nil)
        }
    }
    
    fileprivate func createSecureURL(fromURLString urlString: String) -> URL? {
        let secureURLString = urlString.replacingOccurrences(of: "http:", with: "https:")
        
        guard let secureURL = URL(string: secureURLString) else {
            return nil
        }
        
        return secureURL
    }
    
    fileprivate func getImageURL(fromDescription description: String?) -> URL? {
        guard let description = description else {
            return nil
        }
        
        guard let imageURLStringStartRange = description.range(of: "https://"),
            let imageURLStringEndRange = description.range(of: ".jpg") else {
                return nil
        }
        
        let imageURLStringRange = imageURLStringStartRange.lowerBound..<imageURLStringEndRange.upperBound
        let imageURLString = description.substring(with: imageURLStringRange)
        
        guard let imageURL = URL(string: imageURLString) else {
            return nil
        }
        
        return imageURL
    }
    
    fileprivate func getEpisodeDescription(fromDescription description: String?) -> String? {
        guard let description = description else {
            return nil
        }
        
        guard let rangeOfLastHTMLTagCharacter = description.range(of: ">", options: .backwards, range: nil, locale: nil) else {
            return description
        }
        let episodeDescriptionRange = rangeOfLastHTMLTagCharacter.upperBound..<description.endIndex
        return description.substring(with: episodeDescriptionRange)
    }
}













