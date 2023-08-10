//
//  HomeInteractor.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation
import NetworkStatusObserver
import iTunesAPI

extension HomeInteractor {
    fileprivate enum Constants {
        static let visibleFilterCount = 2
    }
}

protocol HomeInteractorProtocol {
    func createFilters() -> (
        visibleFilters: [String],
        hiddenFilters: [String]
    )
    
    func performQuery(
        searchText: String,
        filter: String
    )
    
    func apiToEntity(_ apiModel: ITunesResultModel) -> SearchCellEntity
    func reloadCoreData()
    
    func isFavorite(_ data: SearchCellEntity) -> Bool
}

protocol HomeInteractorOutputProtocol {
    func onSearchResult(_ data: [ITunesResultModel], forText: String, forFilter: String)
}

final class HomeInteractor {
    var output: HomeInteractorOutputProtocol!
    let service: iTunesAPIProtocol = iTunesAPI()
}

extension HomeInteractor: HomeInteractorProtocol {
    func reloadCoreData() {
        CoreDataManager.shared.reloadData()
    }
    
    func apiToEntity(_ data: ITunesResultModel) -> SearchCellEntity {
        var entity = SearchCellEntity(
            artistId: data.artistId,
            collectionId: data.collectionId,
            trackId: data.trackId,
            trackName: data.trackName,
            artistName: data.artistName,
            collectionName: data.collectionName,
            primaryGenreName: data.primaryGenreName,
            trackPrice: data.trackPrice,
            collectionPrice: data.collectionPrice,
            currency: data.currency,
            imageURLString: data.artworkUrl100
                            ?? data.artworkUrl60
                            ?? data.artworkUrl30,
            previewURLString: data.previewUrl,
            isFavorite: false
        )
        entity.isFavorite = CoreDataManager.shared.exists(entity)
        return entity
    }
    
    func isFavorite(_ data: SearchCellEntity) -> Bool {
        return CoreDataManager.shared.exists(data)
    }
    
    func performQuery(
        searchText: String,
        filter: String
    ) {
        guard let itunesFilter = ITunesFilterConfig.mapping[filter]
        else {
            output.onSearchResult([], forText: searchText, forFilter: filter)
            return
        }
        
        service.performQuery(
            .init(
                term: searchText,
                country: ApplicationConstants.countryCode,
                entity: itunesFilter.entity,
                attribute: itunesFilter.attribute
            )
        ) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                output.onSearchResult(
                    data.results ?? [],
                    forText: searchText,
                    forFilter: filter
                )
            case .failure(_):
                output.onSearchResult(
                    [],
                    forText: searchText,
                    forFilter: filter
                )
            }
        }
    }
    
    func createFilters() -> (visibleFilters: [String], hiddenFilters: [String]) {
        let visible = ApplicationConstants
            .AvailableFilters
            .allCases
            .prefix(Constants.visibleFilterCount)
            .map({$0.rawValue})
        
        let hidden = ApplicationConstants
            .AvailableFilters
            .allCases
            .suffix(Constants.visibleFilterCount+1)
            .map({$0.rawValue})
        
        return (
            visibleFilters: visible,
            hiddenFilters: hidden
        )
    }
}
