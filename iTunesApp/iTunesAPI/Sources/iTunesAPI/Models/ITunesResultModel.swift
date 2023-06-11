//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation

public struct ITunesResultModel: Decodable {
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
    
    public let country: String?
    public let currency: String?
    
    public let primaryGenreName: String?
}
