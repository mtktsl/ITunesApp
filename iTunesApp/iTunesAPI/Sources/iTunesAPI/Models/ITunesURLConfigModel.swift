//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation

public struct ITunesURLConfigModel {
    public let baseURLString: String
    public let routeString: String
    public let queryStarter: String
    public let querySeperator: String
    
    public init(
        baseURLString: String,
        routeString: String,
        queryStarter: String,
        querySeperator: String
    ) {
        self.baseURLString = baseURLString
        self.routeString = routeString
        self .queryStarter = queryStarter
        self.querySeperator = querySeperator
    }
    
    public func generateQueryURLString(_ queryParameters: ITunesParametersModel) -> String {
        var result = ""
        
        result += baseURLString + "/"
        result += routeString
        
        result += queryStarter
        
        result += ITunesParametersModel.params[0]
        result += queryParameters.term.addingPercentEncoding(
            withAllowedCharacters: .alphanumerics
        ) ?? "-"
        
        result += querySeperator
        
        result += ITunesParametersModel.params[1]
        result += queryParameters.country
        
        result += querySeperator
        
        result += ITunesParametersModel.params[2]
        result += queryParameters.entity.rawValue
        
        result += querySeperator
        
        result += ITunesParametersModel.params[3]
        result += queryParameters.attribute.rawValue
        
        return result
    }
}
