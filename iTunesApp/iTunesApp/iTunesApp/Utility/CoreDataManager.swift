//
//  CoreDataManager.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 16.06.2023.
//

import Foundation
import CoreData
import UIKit

protocol CoreDataManagerProtocol {
    func addFavorite(_ entity: SearchCellEntity) -> Bool
    func removeFavorite(_ entity: SearchCellEntity) -> Bool
    func fetchFavorites() -> [SearchCellEntity]
    func reloadData()
    func exists(_ entity: SearchCellEntity) -> Bool
}

final class CoreDataManager {
    
    static let shared: CoreDataManagerProtocol = CoreDataManager()
    
    private var context: NSManagedObjectContext? {
        return  (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    private var lastFetch: [SearchEntityCore] = []
    
    private init() {}
    
    private func saveContext(_ context: NSManagedObjectContext) -> Bool {
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
    
    private func entityToCore(entity: SearchCellEntity, context: NSManagedObjectContext) -> SearchEntityCore {
        let newItem = SearchEntityCore(context: context)
        newItem.artistId = Int64(entity.artistId ?? -1)
        newItem.artistName = entity.artistName
        newItem.collectionId = Int64(entity.collectionId ?? -1)
        newItem.collectionName = entity.collectionName
        newItem.collectionPrice = entity.collectionPrice ?? 0
        newItem.currency = entity.currency
        newItem.imageURLString = entity.imageURLString
        newItem.previewURLString = entity.previewURLString
        newItem.primaryGenreName = entity.primaryGenreName
        newItem.trackId = Int64(entity.trackId ?? -1)
        newItem.trackName = entity.trackName
        newItem.trackPrice = Float(entity.trackPrice ?? 0)
        
        return newItem
    }
    
    private func coreToEntity(core: SearchEntityCore) -> SearchCellEntity {
        let newItem = SearchCellEntity(
            artistId: Int(core.artistId),
            collectionId: Int(core.collectionId),
            trackId: Int(core.trackId),
            trackName: core.trackName,
            artistName: core.artistName,
            collectionName: core.collectionName,
            primaryGenreName: core.primaryGenreName,
            trackPrice: core.trackPrice,
            collectionPrice: core.collectionPrice,
            currency: core.currency,
            imageURLString: core.imageURLString,
            previewURLString: core.previewURLString,
            isFavorite: true
        )
        
        return newItem
    }
}

extension CoreDataManager: CoreDataManagerProtocol {
    func addFavorite(_ entity: SearchCellEntity) -> Bool {
        guard let context = self.context
        else { return false }
        
        let _ = entityToCore(entity: entity, context: context)
        let result = saveContext(context)
        reloadData()
        return result
    }
    
    func removeFavorite(_ entity: SearchCellEntity) -> Bool {
        guard let context = self.context
        else { return false }
        
        var result = false
        
        if let itemToRemove = lastFetch.first(where: {
            $0.trackId == Int(entity.trackId ?? -1)
            && $0.artistId == Int(entity.artistId ?? -1)
            && $0.collectionId == Int(entity.collectionId ?? -1)
        }) {
            context.delete(itemToRemove)
            result = saveContext(context)
        }
        reloadData()
        
        return result
    }
    
    func fetchFavorites() -> [SearchCellEntity] {
        guard let context = self.context
        else {
            lastFetch = []
            return []
        }
        
        if let items = try? context.fetch(SearchEntityCore.fetchRequest()) {
            lastFetch = items
            return lastFetch.map({coreToEntity(core: $0)})
        } else {
            lastFetch = []
            return []
        }
    }
    
    func reloadData() {
        _ = fetchFavorites()
    }
    
    func exists(_ entity: SearchCellEntity) -> Bool {
        lastFetch.contains {
            $0.trackId == Int(entity.trackId ?? -1)
            && $0.artistId == Int(entity.artistId ?? -1)
            && $0.collectionId == Int(entity.collectionId ?? -1)
        }
    }
}
