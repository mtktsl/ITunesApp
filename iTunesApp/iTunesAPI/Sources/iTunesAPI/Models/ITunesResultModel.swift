//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation

public enum ITunesResultKind: String, CaseIterable, Decodable {
    case book
    case album
    case coachedAudio = "coached-audio"
    case featureMovie = "feature-movie"
    case interactiveBooklet = "interactive-booklet"
    case musicVideo = "music-video"
    case pdf
    case podcast
    case podcastEpisode = "podcast-episode"
    case softwarePackage = "software-package"
    case song
    case tvEpisode = "tv-episode"
    case artist
    case unknown
}

public struct ITunesResultModel: Decodable {
    public let kind: ITunesResultKind?
    
    public let artistId: Int?
    public let collectionId: Int?
    public let trackId: Int?
    
    public let artistName: String?
    public let collectionName: String?
    public let trackName: String?
    
    public let previewUrl: String?
    
    public let artworkUrl30: String?
    public let artworkUrl60: String?
    public let artworkUrl100: String?
    
    public let collectionPrice: Float?
    public let trackPrice: Float?
    
    public let releaseDate: String?
    public let trackTimeMillis: Int?
    public let country: String?
    public let currency: String?
    
    public let primaryGenreName: String?
    
    enum CodingKeys: CodingKey {
        case kind
        case artistId
        case collectionId
        case trackId
        case artistName
        case collectionName
        case trackName
        case previewUrl
        case artworkUrl30
        case artworkUrl60
        case artworkUrl100
        case collectionPrice
        case trackPrice
        case releaseDate
        case trackTimeMillis
        case country
        case currency
        case primaryGenreName
    }
    
    //since kind is defined as enum, the decoder fails when an undefined case comes in
    //so we need to detect that if incoming kind is undefined
    //if it is an undefined value, assign "unknown" case value to the kind parameter
    //the reason we need to do this is that if the web api provider decides to add new result type to the "kind" parameter, we don't want our app to reject the whole result.
    //Instead, we accept it but assign "unknown" case to it
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
       
        let decodedKind = try? container.decodeIfPresent(ITunesResultKind.self, forKey: .kind)
        
        if let decodedKind {
            self.kind = decodedKind
        } else {
            self.kind = .unknown
        }
        
        self.artistId = try container.decodeIfPresent(Int.self, forKey: .artistId)
        self.collectionId = try container.decodeIfPresent(Int.self, forKey: .collectionId)
        self.trackId = try container.decodeIfPresent(Int.self, forKey: .trackId)
        self.artistName = try container.decodeIfPresent(String.self, forKey: .artistName)
        self.collectionName = try container.decodeIfPresent(String.self, forKey: .collectionName)
        self.trackName = try container.decodeIfPresent(String.self, forKey: .trackName)
        self.previewUrl = try container.decodeIfPresent(String.self, forKey: .previewUrl)
        self.artworkUrl30 = try container.decodeIfPresent(String.self, forKey: .artworkUrl30)
        self.artworkUrl60 = try container.decodeIfPresent(String.self, forKey: .artworkUrl60)
        self.artworkUrl100 = try container.decodeIfPresent(String.self, forKey: .artworkUrl100)
        self.collectionPrice = try container.decodeIfPresent(Float.self, forKey: .collectionPrice)
        self.trackPrice = try container.decodeIfPresent(Float.self, forKey: .trackPrice)
        self.releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        self.trackTimeMillis = try container.decodeIfPresent(Int.self, forKey: .trackTimeMillis)
        self.country = try container.decodeIfPresent(String.self, forKey: .country)
        self.currency = try container.decodeIfPresent(String.self, forKey: .currency)
        self.primaryGenreName = try container.decodeIfPresent(String.self, forKey: .primaryGenreName)
    }
}
