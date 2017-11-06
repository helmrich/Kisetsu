//
//  CrunchyrollClient.swift
//  Kisetsu
//
//  Created by Tobias Helmrich on 24.06.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import Foundation
import FeedKit
import AEXML

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
        
        var episodeListRequest = URLRequest(url: url)
        episodeListRequest.addValue("en-US", forHTTPHeaderField: "Accept-Language")
        let episodeListDataTask = URLSession.shared.dataTask(with: episodeListRequest) { (data, response, error) in
            guard error == nil else {
                completionHandlerForEpisodeList(nil, error!.localizedDescription)
                return
            }
            
            guard let response = response,
                let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode >= 200 && statusCode <= 299  else {
                    completionHandlerForEpisodeList(nil, "Unsuccessful response status code for episode list request")
                    return
            }
            
            guard let data = data else {
                completionHandlerForEpisodeList(nil, "Couldn't get data for episode list")
                return
            }
            
            guard let feedParser = FeedParser(data: data) else {
                completionHandlerForEpisodeList(nil, "Couldn't create feed parser from received data")
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
                    let episodeGUID: String?
                    let previewImageURL: URL?
                    let crunchyrollURL: URL?
                    
                    var imageSmallURL: URL? = nil
                    var imageMediumURL: URL? = nil
                    var imageThumbnailURL: URL? = nil
                    var imageLargeURL: URL? = nil
                    var imageFullURL: URL? = nil
                    if let rssFeedItemMedia = rssFeedItem.media,
                        let mediaThumbnails = rssFeedItemMedia.mediaThumbnails {
                        for (index, thumbnail) in mediaThumbnails.enumerated() {
                            if let thumbnailURLString = thumbnail.attributes?.url,
                                let thumbnailURL = self.createSecureURL(fromURLString: thumbnailURLString) {
                                switch index {
                                case 0: imageFullURL = thumbnailURL
                                case 1: imageLargeURL = thumbnailURL
                                case 2: imageThumbnailURL = thumbnailURL
                                case 3: imageMediumURL = thumbnailURL
                                case 4: imageSmallURL = thumbnailURL
                                default: break
                                }
                            }
                        }
                    }
                    
                    episodeGUID = rssFeedItem.guid?.value
                    episodeTitle = rssFeedItem.title ?? "No title available"
                    episodeDescription = self.getEpisodeDescription(fromDescription: rssFeedItem.description) ?? "No description available"
                    if let rssFeedItemLink = rssFeedItem.link {
                        crunchyrollURL = URL(string: rssFeedItemLink)
                    } else {
                        crunchyrollURL = nil
                    }
                    
                    let episode = Episode(title: episodeTitle,
                                          description: episodeDescription,
                                          guid: episodeGUID,
                                          mediaId: nil,
                                          number: nil,
                                          crunchyrollURL: crunchyrollURL,
                                          imageSmallURL: imageSmallURL,
                                          imageMediumURL: imageMediumURL,
                                          imageThumbnailURL: imageThumbnailURL,
                                          imageLargeURL: imageLargeURL,
                                          imageFullURL: imageFullURL)
                    episodeList.append(episode)
                }
                
                // Try creating a XML document
                let xmlDocument: AEXMLDocument
                do {
                    xmlDocument = try AEXMLDocument(xml: data)
                } catch {
                    completionHandlerForEpisodeList(episodeList, error.localizedDescription)
                    return
                }
                
                /*
                     If the episode numbers cannot be received call the
                     the completion handler and pass it the episode list
                     that contains episodes without episode numbers
                 */
                guard let channelElementChildren = xmlDocument.root.children.first?.children else {
                    print("Couldn't get channel element children")
                    completionHandlerForEpisodeList(episodeList, nil)
                    return
                }
                
                channelElementChildren.forEach {
                    if $0.name == "item",
                        let episodeNumberString = $0["crunchyroll:episodeNumber"].value,
                        let episodeNumber = Double(episodeNumberString),
                        let guid = $0["guid"].value,
                        let indexOfEpisodeWithMatchingGUID = episodeList.index(where: { $0.guid == guid }) {
                        episodeList[indexOfEpisodeWithMatchingGUID].number = episodeNumber
                        if let mediaId = $0["crunchyroll:mediaId"].value {
                            episodeList[indexOfEpisodeWithMatchingGUID].mediaId = mediaId
                        }
                    }
                }
                
                /*
                 If all episodes in the episode list have an episode
                 number, sort the episode list by numbers and use the
                 sorted episode list. Otherwise (if any of the episode
                 list's episodes doesn't have an episode number), use
                 the initially received episode list
                 */
                let episodeListToUse: [Episode]
                if episodeList.first(where: { $0.number == nil }) == nil {
                    let episodeListSortedByEpisodeNumber = episodeList.sorted {
                        guard let lhsEpisodeNumber = $0.number,
                            let rhsEpisodeNumber = $1.number else {
                                return false
                        }
                        return lhsEpisodeNumber < rhsEpisodeNumber
                    }
                    episodeListToUse = episodeListSortedByEpisodeNumber
                } else {
                    episodeListToUse = episodeList
                }
                
                if let selectedAnimeSeries = DataSource.shared.selectedSeries as? AnimeSeries {
                    selectedAnimeSeries.episodes = episodeListToUse
                }
                
                completionHandlerForEpisodeList(episodeListToUse, nil)
            }
        }
        episodeListDataTask.resume()
    }
    
    fileprivate func createSecureURL(fromURLString urlString: String) -> URL? {
        let urlStringWithoutImageSubdomains = urlString.replacingOccurrences(of: "img1.ak.", with: "")
        let secureURLString = urlStringWithoutImageSubdomains.replacingOccurrences(of: "http:", with: "https:")
        
        guard let secureURL = URL(string: secureURLString) else {
            return nil
        }
        
        return secureURL
    }
    
    fileprivate func getEpisodeDescription(fromDescription description: String?) -> String? {
        guard let description = description else {
            return nil
        }
        
        guard let rangeOfLastHTMLTagCharacter = description.range(of: ">", options: .backwards, range: nil, locale: nil) else {
            return description
        }
        
        let episodeDescriptionRange = rangeOfLastHTMLTagCharacter.upperBound..<description.endIndex
        let episodeDescription = description.substring(with: episodeDescriptionRange)
        
        guard episodeDescription.characters.count > 0 else {
            return "No description available"
        }
        return episodeDescription
    }
}
