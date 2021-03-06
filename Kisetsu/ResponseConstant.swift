//
//  ResponseConstant.swift
//  AniManager
//
//  Created by Tobias Helmrich on 21.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

extension ResponseConstant {
    struct ResponseKey {
        struct Authentication {
            static let accessToken = "access_token"
            static let tokenType = "token_type"
            static let expires = "expires"
            static let expiresInSeconds = "expires_in"
            static let refreshToken = "refresh_token"
        }
        
        struct Series {
            static let id = "id"
            static let seriesType = "series_type"
            static let titleRomaji = "title_romaji"
            static let titleEnglish = "title_english"
            static let titleJapanese = "title_japanese"
            static let mediaType = "type"
            static let synonyms = "synonyms"
            static let genres = "genres"
            static let adult = "adult"
            static let classification = "classification"
            static let averageScore = "average_score"
            static let popularity = "popularity"
            static let imageSmallURL = "image_url_sml"
            static let imageMediumURL = "image_url_med"
            static let imageLargeURL = "image_url_lge"
            static let imageBannerURL = "image_url_banner"
            static let season = "season"
            static let description = "description"
            static let favourite = "favourite"
            static let characters = "characters"
            static let tags = "tags"
            static let relations = "relations"
            static let relationsAnime = "relations_anime"
            static let relationsManga = "relations_manga"
            static let relationType = "relation_type"
        }
        
        struct GenreList {
            static let genre = "genre"
            static let id = "id"
        }
        
        struct AnimeSeries {
            static let numberOfTotalEpisodes = "total_episodes"
            static let durationPerEpisode = "duration"
            static let airingStatus = "airing_status"
            static let youtubeVideoId = "youtube_id"
            static let source = "source"
            static let externalLinksStrings = "external_links"
            static let studios = "studio"
            static let airing = "airing"
            static let airingCountdownUntilNextEpisodeInSeconds = "countdown"
            static let airingNextEpisodeNumber = "next_episode"
        }
        
        struct MangaSeries {
            static let totalVolumes = "total_volumes"
            static let totalChapters = "total_chapters"
            static let publishingStatus = "publishing_status"
        }
        
        struct Character {
            static let id = "id"
            static let firstName = "name_first"
            static let lastName = "name_last"
            static let japaneseName = "name_japanese"
            static let imageMediumURL = "image_url_med"
            static let imageLargeURL = "image_url_lge"
            static let info = "info"
            static let role = "role"
            static let favourite = "favourite"
            static let actor = "actor"
        }
        
        struct Tag {
            static let name = "name"
            static let description = "description"
            static let isSpoiler = "spoiler"
        }
        
        struct ExternalLink {
            static let site = "site"
            static let url = "url"
        }
        
        struct Studio {
            static let name = "studio_name"
        }
        
        struct Staff {
            static let id = "id"
            static let firstName  = "name_first"
            static let lastName = "name_last"
            static let firstNameJapanese = "name_first_japanese"
            static let lastNameJapanese = "name_last_japanese"
            static let language = "language"
            static let imageMediumURL = "image_url_med"
            static let imageLargeURL = "image_url_lge"
            static let info = "info"
            static let favourite = "favourite"
        }
        
        struct User {
            static let id = "id"
            static let displayName = "display_name"
            static let imageMediumURL = "image_url_med"
            static let imageLargeURL = "image_url_lge"
            static let imageBannerURL = "image_url_banner"
            static let animeTime = "anime_time"
            static let readMangaChapters = "manga_chap"
            static let about = "about"
            static let adultContent = "adult_content"
            static let advancedRating = "advanced_rating"
            static let advancedRatingNames = "advanced_rating_names"
            static let scoreType = "score_type"
        }
        
        struct List {
            static let allLists = "lists"
            static let finishedOn = "finished_on"
            static let itemListStatus = "list_status"
            static let userScore = "score"
            struct AnimeList {
                static let watchedEpisodes = "episodes_watched"
            }
            struct MangaList {
                static let readChapters = "chapters_read"
                static let readVolumes = "volumes_read"
            }
        }
    }
}
