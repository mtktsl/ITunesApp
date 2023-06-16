//
//  CoreDataManager.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 16.06.2023.
//

import Foundation
import CoreData
import UIKit

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private var context: NSManagedObjectContext? {
        return  (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    private var lastFetch: [SearchEntityCore] = []
    
    private init() {}
    
    private func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print("ERROR saving coredata")
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
    
    func addFavorite(_ entity: SearchCellEntity) {
        guard let context = self.context
        else { return }
        
        let _ = entityToCore(entity: entity, context: context)
        saveContext(context)
        reloadData()
    }
    
    func removeFavorite(_ entity: SearchCellEntity) {
        guard let context = self.context
        else { return }
        
        if let itemToRemove = lastFetch.first(where: {
            $0.trackId == Int(entity.trackId ?? -1)
            && $0.artistId == Int(entity.artistId ?? -1)
            && $0.collectionId == Int(entity.collectionId ?? -1)
        }) {
            context.delete(itemToRemove)
            saveContext(context)
        }
        reloadData()
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
