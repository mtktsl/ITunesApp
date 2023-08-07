//
//  ApplicationConstants.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation
import iTunesAPI

enum ApplicationConstants {
    //url config for itunes api
    static let urlConfig = ITunesURLConfigModel(
        baseURLString: "https://itunes.apple.com",
        routeString: "search",
        queryStarter: "?",
        querySeperator: "&"
    )
    
    //country code for the user to be used in itunes api searches
    static var countryCode: String {
        if #available(iOS 16, *) {
            return Locale.current.region?.identifier.lowercased() ?? "us"
        } else {
            return Locale.current.regionCode?.lowercased() ?? "us"
        }
    }
    
    //Available itunes api search filters among the app
    enum AvailableFilters: String, CaseIterable {
        case all = "All"
        case music = "Music"
        case album = "Album"
        case artist = "Artist"
        case movie = "Movie"
    }
    
    enum ImageAssets {
        static let loading = "loading"
    }
    
    enum SystemImageNames {
        static let exclamationMarkTriangle = "exclamationmark.triangle"
        static let textMagnifyingGlass = "text.magnifyingglass"
    }
}
