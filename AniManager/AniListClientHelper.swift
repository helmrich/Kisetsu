//
//  AniListClientHelper.swift
//  AniManager
//
//  Created by Tobias Helmrich on 15.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

extension AniListClient {
    
    // This method is used to get data for a single image from a specified URL string
    func getImageData(fromUrlString urlString: String, completionHandlerForImageData: @escaping (_ imageData: Data?, _ errorMessage: String?) -> Void) {
        
        // URL creation and request configuration
        guard let url = URL(string: urlString) else {
            completionHandlerForImageData(nil, "Couldn't create a URL from the provided URL string")
            return
        }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Error Handling
            if let errorMessage = self.checkDataTaskResponseForError(data: data, response: response, error: error) {
                completionHandlerForImageData(nil, errorMessage)
                return
            }
            
            let data = data!
            
            completionHandlerForImageData(data, nil)
            
        }
        
        task.resume()
    }
    
    /*
     This method takes the three arguments of data task's completion handler
     as parameters and checks if:
     */
    func checkDataTaskResponseForError(data: Data?, response: URLResponse?, error: Error?) -> String? {
        // - There was an error
        guard error == nil else {
            return error!.localizedDescription
        }
        
        // - The status code indicates a successful response
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
            statusCode >= 200 && statusCode <= 299 else {
                return "Unsuccessful response status code"
        }
        
        // - There is data
        guard let _ = data else {
            return "Couldn't retrieve data"
        }
        
        return nil
        
    }
    
    /*
        This method creates a "default" request for AniList by adding
        values (bearer access token, content type x-www-form-urlencoded) 
        that are needed to access the resource server on the resource
        owner's behalf to the belonging HTTP header fields
     */
    func createDefaultRequest(withUrl url: URL) -> NSMutableURLRequest {
        // Create request from URL
        let request = NSMutableURLRequest(url: url)
        
        // Add HTTP header field values
        request.addValue(AniListConstant.HeaderFieldValue.contentType, forHTTPHeaderField: AniListConstant.HeaderFieldName.contentType)
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "accessToken")!)", forHTTPHeaderField: AniListConstant.HeaderFieldName.authorization)
        
        return request
    }
    
    /*
     This method takes in a path (like "browse/{seriesType}") and a dictionary of
     parameters (parameterKey:parameterValue) and creates an AniList URL from it
     by using an URLComponents object where the path will be appended to the base
     URL of the AniList API, a query string will be created from the parameters
     and assigned to the URLComponents' object's queryItems property (if there were parameters)
     */
    func createAniListUrl(withPath path: String, andParameters parameters: [String:Any]) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = AniListConstant.URL.scheme
        urlComponents.host = AniListConstant.URL.host
        urlComponents.path = "\(AniListConstant.URL.basePath)\(path)"
        
        var queryItems = [URLQueryItem]()
        for (parameterName, parameterValue) in parameters {
            let queryItem = URLQueryItem(name: parameterName, value: "\(parameterValue)")
            queryItems.append(queryItem)
        }
        
        if queryItems.count > 0 {
            urlComponents.queryItems = queryItems
        }
        
        return urlComponents.url
        
    }
    
    /*
     This function takes in a path string and replacing pairs as parameters.
     The pairs dictionary should contain placeholder strings as a key and
     the string they should be replaced by as a correspondent value
     */
    func replacePlaceholders(inPath path: String, withReplacingPairs pairs: [String:String]) -> String {
        var newPath = path
        for (placeholder, replacement) in pairs {
            newPath = newPath.replacingOccurrences(of: "{\(placeholder)}", with: replacement)
        }
        return newPath
    }
    
    /*
        This function creates a HTTP body from a dictionary with key-value pairs.
        It first iterates over all items of the dictionary and appends them to a
        HTTP body string. When it iterated over all key-value pairs it returns
        an encoded data representation of the HTTP body string which can be used
        as the HTTP body
     */
    func createHttpBody(withKeyValuePairs keyValuePairs: [String:Any]) -> Data? {
        var httpBodyString = "{"
        for (key, value) in keyValuePairs {
            if httpBodyString == "{" {
                httpBodyString.append("\"\(key)\":\"\(value)\"")
            } else {
                httpBodyString.append(",\"\(key)\":\"\(value)\"")
            }
        }
        httpBodyString.append("}")
        
        return httpBodyString.data(using: .utf8)
    }
    
    // This method tries to deserialize given data into a JSON object
    func deserializeJson(fromData data: Data) -> Any? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return jsonObject
        } catch {
            print("Error when trying to deserialize JSON: \(error.localizedDescription)")
            return nil
        }
    }
    
    /*
        This method checks if an access token is still valid
        by comparing the access token's expiration timestamp
        to the timestamp of the current time
     */
    func isAccessTokenValid() -> Bool {
        let expirationTimestamp = UserDefaults.standard.integer(forKey: "expirationTimestamp")
        let timestampNow = Int(Date().timeIntervalSince1970)
        let isAccessTokenValid = expirationTimestamp > timestampNow
        return isAccessTokenValid
    }
}
