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
    func testQuery()
    func createFilters() -> (
        visibleFilters: [String],
        hiddenFilters: [String]
    )
    
    func performQuery(
        searchText: String,
        filter: String
    )
}

protocol HomeInteractorOutputProtocol {
    func onSearchResult(_ data: [ITunesResultModel])
}

final class HomeInteractor {
    var output: HomeInteractorOutputProtocol!
    let service = iTunesAPI(
        sourceURL: ApplicationConstants.urlConfig
    )
}

extension HomeInteractor: HomeInteractorProtocol {
    func performQuery(
        searchText: String,
        filter: String
    ) {
        guard let filter = ITunesFilterConfig.mapping[filter]
        else {
            output.onSearchResult([])
            return
        }
        
        service.performQuery(
            .init(
                term: searchText,
                country: ApplicationConstants.countryCode,
                entity: filter.entity,
                attribute: filter.attribute
            )
        ) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                output.onSearchResult(data.results ?? [])
            case .failure(_):
                output.onSearchResult([])
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
    

    func testQuery() {
        
        let service = iTunesAPI(sourceURL: ApplicationConstants.urlConfig)
        
        let testURLString = ApplicationConstants
            .urlConfig
                .generateQueryURLString(
                        .init(
                            term: "beni çok sev",
                            country: ApplicationConstants.countryCode,
                            entity: .song,
                            attribute: .songTerm
                        )
        )
        
        print(testURLString)
        
        service.performQuery(
            .init(term: "tarkan",
                  country: "tr",
                  entity: .allTrack,
                  attribute: .songTerm)
        ) { [weak self] result in
            guard let _ = self else { return }
            switch result {
            case .success(let data):
                if let first = data.results?.first {
                    //print(first)
                    print(first.kind?.rawValue)
                } else {
                    print("nil")
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
