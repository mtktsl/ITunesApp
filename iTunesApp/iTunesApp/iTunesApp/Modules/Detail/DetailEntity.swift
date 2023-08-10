//
//  DetailEntity.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 10.08.2023.
//

import Foundation

final class DetailEntity {
    
    enum CoreDataError {
        case addFailure
        case removeFailure
    }
    
    enum CoreDataResult {
        case success
        case failure(error: CoreDataError)
    }
}
