//
//  HomeInteractor.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation
import NetworkStatusObserver
import iTunesAPI

protocol HomeInteractorProtocol {
    func testQuery()
}

protocol HomeInteractorOutputProtocol {
}

final class HomeInteractor {
    var output: HomeInteractorOutputProtocol!
    init() {
        //NetworkStatusObserver.shared.delegate = self
    }
}

extension HomeInteractor: HomeInteractorProtocol {

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
                    //print(data.resultCount)
                } else {
                    print("nil")
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
