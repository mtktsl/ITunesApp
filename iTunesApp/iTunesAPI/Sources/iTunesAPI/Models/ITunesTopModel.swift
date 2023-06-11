//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation

public struct ITunesTopModel: Decodable {
    public var resultCount: Int?
    public var results: [ITunesResultModel]?
}
