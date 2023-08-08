//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 8.08.2023.
//

import Foundation

internal enum Constants {
    //url config for itunes api
    static let urlConfig = ITunesURLConfigModel(
        baseURLString: "https://itunes.apple.com",
        routeString: "search",
        queryStarter: "?",
        querySeperator: "&"
    )
}
