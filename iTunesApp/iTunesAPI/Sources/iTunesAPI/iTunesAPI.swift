import Foundation
import NetworkDataAPI

public protocol iTunesAPIProtocol {
    var sourceURL: ITunesURLConfigModel { get }
    
    func config(_ url: ITunesURLConfigModel)
    
    func performQuery(
        _ parameters: ITunesParametersModel,
        completion: @escaping (Result<ITunesTopModel, DataProviderServiceError>) -> Void
    )
    
    func fetchImage(
        _ urlString: String,
        completion: @escaping (Result<Data, DataProviderServiceError>) -> Void
    )
}

public final class iTunesAPI {
    public private(set) var sourceURL: ITunesURLConfigModel
    
    public init(sourceURL: ITunesURLConfigModel) {
        self.sourceURL = sourceURL
    }
}

extension iTunesAPI: iTunesAPIProtocol {
    public func config(_ url: ITunesURLConfigModel) {
        self.sourceURL = url
    }
    
    public func performQuery(
        _ parameters: ITunesParametersModel,
        completion: @escaping (Result<ITunesTopModel, DataProviderServiceError>) -> Void
    ) {
        let urlString = sourceURL.generateQueryURLString(parameters)
        
        DataProviderService.shared.fetchData(
            from: urlString,
            dataType: ITunesTopModel.self,
            decode: true) { result in
                switch result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    public func fetchImage(
        _ urlString: String,
        completion: @escaping (Result<Data, DataProviderServiceError>) -> Void
    ) {
        DataProviderService.shared.fetchData(
            from: urlString,
            dataType: Data.self,
            decode: false) { [weak self] result in
                guard let _ = self else { return }
                switch result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
