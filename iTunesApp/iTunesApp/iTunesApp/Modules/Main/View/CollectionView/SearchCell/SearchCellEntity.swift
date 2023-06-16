//
//  SearchCellEntity.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 14.06.2023.
//

import Foundation

struct SearchCellEntity {
    let artistId: Int?
    let collectionId: Int?
    let trackId: Int?
    
    let trackName: String?
    let artistName: String?
    let collectionName: String?
    let primaryGenreName: String?
    
    let trackPrice: Float?
    let collectionPrice: Float?
    let currency: String?
    
    let imageURLString: String?
    let previewURLString: String?
    
    var isFavorite: Bool
}
