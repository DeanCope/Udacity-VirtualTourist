//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Dean Copeland on 5/5/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

// MARK: - FlickrClient (Constants)

extension FlickrClient {
    
    // MARK: Errors
    public enum FlickrClientError: Error {
        case connectionFailed(method: String, errorString: String)
        case noStatusCode(method: String)
        case badStatusCode(code: String, url: String)
        case noDataReturned
        case parseFailed(detail: String)
        case otherError(reason: String)
        
        var description: String {
            switch self {
            case .connectionFailed(let method, let errorString): return "Connection failed for \(method): \(errorString)"
            case .noStatusCode(let method): return "No status code received for \(method)"
            case .badStatusCode(let code): return "Bas status code received: \(code)"
            case .noDataReturned: return "No data returned"
            case .parseFailed(let detail): return "Parse failed: \(detail)"
            case .otherError(let reason): return "Error: \(reason)"
            }
        }
    }
    
    // MARK: Constants
    struct Constants {
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest/"
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Account
        static let SearchPhotos = "flickr.photos.search"
    }
    
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let Method = "method"
        static let Format = "format"
        static let NoJsonCallback = "nojsoncallback"
        static let APIKey = "api_key"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Extras = "extras"
        static let PerPage = "per_page"
    }
    
    // MARK: Parameter Values
    struct ParameterValues {
        static let APIKey = "a6d819499131071f158fd740860a5a88"
        static let Json = "json"
        static let NoJsonCallbackTrue = "1"
        static let Extras = "url_s"
    }
    
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Id = "id"
        static let PhotoURLString = "url_s"
    }
 
}
