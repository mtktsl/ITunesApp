//
//  ApplicationConstants.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation
import iTunesAPI

enum ApplicationConstants {
    static let urlConfig = ITunesURLConfigModel(
        baseURLString: "https://itunes.apple.com",
        routeString: "search",
        queryStarter: "?",
        querySeperator: "&"
    )
    
    static var countryCode: String {
        if #available(iOS 16, *) {
            return Locale.current.region?.identifier.lowercased() ?? "us"
        } else {
            return Locale.current.regionCode?.lowercased() ?? "us"
        }
    }
}
