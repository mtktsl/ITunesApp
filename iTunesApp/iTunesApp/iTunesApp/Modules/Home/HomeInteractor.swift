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
        static let searchDelay = 0.5
    }
}

protocol HomeInteractorProtocol {
    func createFilters() -> (
        visibleFilters: [String],
        hiddenFilters: [String]
    )
    
    func performQuery(
        searchText: String,
        filterText: String
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
    var service: iTunesAPIProtocol = iTunesAPI()
    var coreDataManager: CoreDataManagerProtocol = CoreDataManager.shared
    
    var searchQueryWorkItem: DispatchWorkItem?
    
    private func makeRequest(
        searchText: String,
        filterText: String
    ) {
        guard let itunesFilter = ITunesFilterConfig.mapping[filterText]
        else {
            output.onSearchResult([], forText: searchText, forFilter: filterText)
            return
        }
        
        _ = service.performQuery(
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
                    forFilter: filterText
                )
            case .failure(_):
                output.onSearchResult(
                    [],
                    forText: searchText,
                    forFilter: filterText
                )
            }
        }
    }
}

extension HomeInteractor: HomeInteractorProtocol {
    func reloadCoreData() {
        coreDataManager.reloadData()
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
        entity.isFavorite = coreDataManager.exists(entity)
        return entity
    }
    
    func isFavorite(_ data: SearchCellEntity) -> Bool {
        return coreDataManager.exists(data)
    }
    
    func performQuery(
        searchText: String,
        filterText: String
    ) {
        searchQueryWorkItem?.cancel()
        searchQueryWorkItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            makeRequest(searchText: searchText, filterText: filterText)
        }
        if searchQueryWorkItem != nil {
            DispatchQueue.main.asyncAfter(
                deadline: .now() + Constants.searchDelay,
                execute: searchQueryWorkItem!
            )
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
