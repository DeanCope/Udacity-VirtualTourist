//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Dean Copeland on 5/5/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation

// MARK: - FlickrClient: NSObject

class FlickrClient : NSObject {
    
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    
    // MARK: GET
    
    func taskForGETMethod(parameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: [String: AnyObject]?, _ error: FlickrClientError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        var parametersWithApiKey = parameters
        parametersWithApiKey[ParameterKeys.APIKey] = ParameterValues.APIKey as AnyObject?
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: flickrURLFromParameters(parametersWithApiKey, withPathExtension: nil))
        
        //print(request.url!)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: FlickrClientError) {
                completionHandlerForGET(nil, error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError(.connectionFailed(method: "GET", errorString: error!.localizedDescription))
                return
            }
            
            /* GUARD: Did we get a status code? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                sendError(.noStatusCode(method: "GET"))
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard statusCode >= 200 && statusCode <= 299 else {
                sendError(.badStatusCode(code: String(statusCode), url: String(describing: request.url)))
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError(.noDataReturned)
                return
            }
                        
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    
    // MARK: Helpers
    
    // substitute the key for the value that is contained within the method name
    /*
    func substituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
 */
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: [String: AnyObject]?, _ error: FlickrClientError?) -> Void) {
        
     //   print("Json Data:")
     //   print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
        
        var parsedResult: [String: AnyObject]?
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
        } catch let error {
            completionHandlerForConvertData(nil, .parseFailed(detail: error.localizedDescription))
        }
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // create a Flickr URL from parameters
    private func flickrURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = FlickrClient.Constants.ApiScheme
        components.host = FlickrClient.Constants.ApiHost
        components.path = FlickrClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}

