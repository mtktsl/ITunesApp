//
//  HomeEntity.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 14.06.2023.
//

import Foundation
import iTunesAPI

struct ITunesFilterModel {
    let entity: ITunesEntityParameter
    let attribute: ITunesAttributeParameter
}

//Filter config mapping to be used in itunes api searches
enum ITunesFilterConfig {
    
    static let mapping: [String: ITunesFilterModel] = [
        ApplicationConstants
            .AvailableFilters.all.rawValue: .init(
                entity: .allTrack,
                attribute: .mixTerm
        ),
        
        ApplicationConstants
            .AvailableFilters.music.rawValue: .init(
                entity: .musicTrack,
                attribute: .songTerm
        ),
        
        ApplicationConstants
            .AvailableFilters.album.rawValue: .init(
                entity: .musicTrack,
                attribute: .albumTerm
        ),
        
        ApplicationConstants
            .AvailableFilters.artist.rawValue: .init(
                entity: .allTrack,
                attribute: .allArtistTerm
        ),
        
        ApplicationConstants
            .AvailableFilters.movie.rawValue: .init(
                entity: .movie,
                attribute: .movieTerm
        )
    ]
}
