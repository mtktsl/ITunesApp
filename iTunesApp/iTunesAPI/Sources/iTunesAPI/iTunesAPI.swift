import Foundation
import NetworkDataAPI

public protocol iTunesAPIProtocol {
    var sourceURL: ITunesURLConfigModel { get }
    
    func config(_ url: ITunesURLConfigModel)
    
    func performQuery(
        _ parameters: ITunesParametersModel,
        completion: @escaping (Result<ITunesTopModel, DataProviderServiceError>) -> Void
    ) -> URLSessionDataTask?
    
    func fetchImage(
        _ urlString: String,
        completion: @escaping (Result<Data, DataProviderServiceError>) -> Void
    ) -> URLSessionDataTask?
}

public final class iTunesAPI {
    public private(set) var sourceURL: ITunesURLConfigModel = Constants.urlConfig
    public init() {}
}

extension iTunesAPI: iTunesAPIProtocol {
    public func config(_ url: ITunesURLConfigModel) {
        self.sourceURL = url
    }
    
    public func performQuery(
        _ parameters: ITunesParametersModel,
        completion: @escaping (Result<ITunesTopModel, DataProviderServiceError>) -> Void
    ) -> URLSessionDataTask? {
        let urlString = sourceURL.generateQueryURLString(parameters)
        
        return DataProviderService.shared.fetchData(
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
    ) -> URLSessionDataTask? {
        return DataProviderService.shared.fetchData(
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
