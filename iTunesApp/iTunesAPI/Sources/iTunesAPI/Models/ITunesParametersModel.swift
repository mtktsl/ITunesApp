//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation

public enum ITunesEntityParameter: String {
    //movie
    case movieArtist = "movieArtist"
    case movie = "movie"
    
    //podcast
    case podcastAuthor = "podcastAuthor"
    case podcast = "podcast"
    
    //music
    case musicArtist = "musicArtist"
    case musicTrack = "musicTrack"
    case album = "album"
    case musicVideo = "musicVideo"
    case mix = "mix"
    case song = "song"
    
    //audiobook
    case audiobookAuthor = "audiobookAuthor"
    case audiobook = "audiobook"
    
    //shortfilm
    case shortFilmArtist = "shortFilmArtist"
    case shortFilm = "shortFilm"
    
    //tvShow
    case tvEpisode = "tvEpisode"
    case tvSeason = "tvSeason"
    
    //software
    case software = "software"
    case iPadSoftware = "iPadSoftware"
    case macSoftware = "macSoftware"
    
    //ebook
    case ebook = "ebook"
    
    //all
    case allArtist = "allArtist"
    case allTrack = "allTrack"
}

public enum ITunesAttributeParameter: String {
    //movie
    case actorTerm = "actorTerm"
    case genreIndex = "genreIndex"
    case artistTerm = "artistTerm"
    case shortFilmTerm = "shortFilmTerm"
    case producerTerm = "producerTerm"
    case ratingTerm = "ratingTerm"
    case directorTerm = "directorTerm"
    case releaseYearTerm = "releaseYearTerm"
    case featureFilmTerm = "featureFilmTerm"
    case movieArtistTerm = "movieArtistTerm"
    case movieTerm = "movieTerm"
    case ratingIndex = "ratingIndex"
    case descriptionTerm = "descriptionTerm"
    
    //podcast
    case titleTerm = "titleTerm"
    case languageTerm = "languageTerm"
    case authorTerm = "authorTerm"
    case keywordsTerm = "keywordsTerm"
    
    //music
    case mixTerm = "mixTerm"
    case composerTerm = "composerTerm"
    case albumTerm = "albumTerm"
    case songTerm = "songTerm"
    
    //software
    case softwareDeveloper = "softwareDeveloper"
    
    //tvshow
    case tvEpisodeTerm = "tvEpisodeTerm"
    case showTerm = "showTerm"
    case tvSeasonTerm = "tvSeasonTerm"
    
    //all
    case allArtistTerm = "allArtistTerm"
    case allTrackTerm = "allTrackTerm"
}

public struct ITunesParametersModel {
    public let term: String
    public let country: String
    public let entity: ITunesEntityParameter
    public let attribute: ITunesAttributeParameter
    
    static let params = [
        "term=",
        "country=",
        "entity=",
        "attribute="
    ]
    
    public init(
        term: String,
        country: String,
        entity: ITunesEntityParameter,
        attribute: ITunesAttributeParameter
    ) {
        self.term = term
        self.country = country
        self.entity = entity
        self.attribute = attribute
    }
}
